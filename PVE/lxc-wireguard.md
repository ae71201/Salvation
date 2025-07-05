# 自用安装教程
- PS：主路由需要做好端口转发

## 一、Proxmox VE 安装 LXC 模板，系统选择 Debian12

## 二换源，添加[国内源](https://mirrors.help/debian/)
```
cat << EOF > /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
```
### 更新系统
```
apt update && apt dist-upgrade -y
```

### 安装必要插件
```
apt install wireguard resolvconf iptables -y
```

## 三、开启 V4 & V6 路由转发
```
echo -e "net.ipv4.ip_forward = 1\nnet.ipv6.conf.all.forwarding = 1" >>/etc/sysctl.conf
```

## 四、创建密钥

### 进入目录
```
cd /etc/wireguard
```
### 创建密钥
```
wg genkey | tee server_privatekey | wg pubkey > server_publickey
```
```
wg genkey | tee client_privatekey | wg pubkey > client_publickey
```
## 五、创建服务器配置文件， ip a 查看本机网卡

### 服务端配置
```
echo "
[Interface]
PrivateKey = $(cat server_privatekey) #server私钥
Address = 192.168.21.1/24 #本机虚拟局域网IP

PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
#注意eth0需要为本机网卡名称

ListenPort = 11201 # 监听端口：注意不要使用已经使用的端口
DNS = 192.168.2.23 #任意DNS服务器，可以是内网路由器
[Peer]
PublicKey = $(cat client_publickey) #client的公钥
AllowedIPs = 192.168.21.10/32 #客户端所使用的IP" > wg0.conf
```
### 客户端配置
```
echo "
[Interface]
PrivateKey = $(cat client_privatekey) #client的私钥
Address = 192.168.21.10/24 #此处为peer规定的客户端IP
DNS = 192.168.2.23 #设置一个dns

[Peer]
PublicKey = $(cat server_publickey) #server的公钥
AllowedIPs = 0.0.0.0/0, ::/0 #此处为允许的服务器IP
Endpoint = 自己的域名:11201 #服务器对端IP+端口，需要修改域名
PersistentKeepalive = 25 " > client.conf
```
## 六、下载客户端配置
~~~
进入/etc/wireguard/目录，下载client.conf导入手机&电脑wireguard即可
~~~

## 七、启动wg
### 设置开机自启
```
systemctl enable wg-quick@wg0
```
### 立即启动wg
```
wg-quick up wg0
```
### 查看接口
```
wg
```
### 重启一下debian，确定还能连上

## 八、后记
### 1、如果重启后，输出不为1，说明转发不成功
```
cat /proc/sys/net/ipv4/ip_forward
```
### 2、命令
```
crontab -e
```
### 3、最后添加如下命令，保存重启
```
@reboot sleep 15 && echo 1 > /proc/sys/net/ipv4/ip_forward
```
