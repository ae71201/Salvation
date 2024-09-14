# 自用安装教程
- PS：下载compatible的版本: 使用 GOAMD64=v1 标签进行编译

## 一、Proxmox VE 安装 LXC 模板，系统选择 Debian12

## 二、开启 TUN 模式
- PS：在 PVE 里面 Shell 操作

### 使用以下命令（把下面的 LXCID 修改成你实际的ID号），开启 TUN 模式
```
echo -e "lxc.cgroup2.devices.allow: c 10:200 rwm\nlxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >>/etc/pve/lxc/LXCID.conf
```

## 三、换源
- PS：在创建的 mihomo 的 LXC 容器操作

### 使用以下命令，添加 [清华源](https://mirrors.help/debian/) 
```
cat << EOF > /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
```

## 四、开启路由转发&开启ssh

### 使用以下命令，开启 V4 路由转发（PVE 下开启 v6 转发获取不到 v6 公网 IP）
```
echo -e "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
```
### 使用以下命令，开启 V4 & V6 路由转发
```
echo -e "net.ipv4.ip_forward = 1\nnet.ipv6.conf.all.forwarding = 1" >>/etc/sysctl.conf
```
### 使用以下命令，开启SSH权限
```
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && systemctl restart sshd
```

## 五、更新系统

### 使用以下命令，更新系统
```
apt update && apt dist-upgrade -y
```
## 六、安装必须插件

### 使用以下命令，安装必要插件
```
apt install -y git wget
```

## 七、下载、安装、配置

### 1、使用以下命令，创建 mihomo 文件夹
~~~
mkdir /etc/mihomo
~~~
### 2、使用以下命令，下载 mihomo 内核
#### PS： 首先查看 [最新版](https://wiki.metacubex.one/startup/#__tabbed_1_2) 的版本号，下面命令里面的 **版本号** ，修改成最新的版本号！！！
~~~
wget https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-amd64-compatible-alpha-版本号.gz
~~~
### 3、使用以下命令，解压文件（需要修改成你下载的版本号！！！）
~~~
gzip -d mihomo-linux-amd64-compatible-alpha-版本号.gz
~~~
### 4、使用以下命令，授权最高权限（需要修改成你下载的版本号！！！）
~~~
chmod 755 mihomo-linux-amd64-compatible-alpha-版本号
~~~
### 5、使用以下命令，重名名为 mihomo 并移动到 /usr/local/bin/ （需要修改成你下载的版本号！！！）
~~~
mv mihomo-linux-amd64-compatible-alpha-版本号 /usr/local/bin/mihomo
~~~
### 6、使用以下命令，把配置文件全部粘贴进去，按 Ctrl+x，按y保存。
- ps：使用官方推荐配置或者自己按照官方例子修改，也可以使用我提供的 [config](https://github.com/ae71201/mihomo/blob/main/config/config.yaml) 文件
~~~
nano /etc/mihomo/config.yaml
~~~

### 7、使用以下命令，安装 UI 界面（国内加速地址）
```
git clone https://mirror.ghproxy.com/https://github.com/metacubex/metacubexd.git -b gh-pages /etc/mihomo/ui
```

#### 7.1使用以下命令，更新UI界面(metacubexd)
```
git -C /root/mihomo/ui pull -r
```

### 8、使用以下命令，创建 [systemd](https://wiki.metacubex.one/startup/service/) 配置文件
```
cat << EOF > /etc/systemd/system/mihomo.service
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
After=network.target NetworkManager.service systemd-networkd.service iwd.service

[Service]
Type=simple
LimitNPROC=500
LimitNOFILE=1000000
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
Restart=always
ExecStartPre=/usr/bin/sleep 1s
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF
```

## 八、启动 mihomo

### 1、使用以下命令，重新加载 systemd
~~~
systemctl daemon-reload
~~~

### 2、使用以下命令，设置开机启动 mihomo
~~~
systemctl enable mihomo
~~~

### 3、使用以下命令，立即启动 mihomo
~~~
systemctl start mihomo
~~~

### 4、使用以下命令，检查 mihomo 运行状况
~~~
systemctl status mihomo
~~~

### 5、使用以下命令，检查 mihomo 运行日志
~~~
journalctl -u mihomo -o cat -e
~~~

### 6、使用以下命令，重新加载 mihomo
~~~
systemctl reload mihomo
~~~

