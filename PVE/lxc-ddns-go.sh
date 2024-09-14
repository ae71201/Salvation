#!/bin/bash

# 获取DDNS-Go的最新版本号
VERSION=$(wget -qO- https://github.com/jeessy2/ddns-go/releases | grep -oP 'tag/v\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

# 检查是否获取到版本号
if [[ -z "$VERSION" ]]; then
    echo "获取最新版本号失败。"
    exit 1
else
    echo "最新版本号：$VERSION"
    
    # 构造下载链接，使用mirror.ghproxy.com代理下载
    DOWNLOAD_URL="https://mirror.ghproxy.com/https://github.com/jeessy2/ddns-go/releases/download/v$VERSION/ddns-go_${VERSION}_linux_x86_64.tar.gz"
    echo "下载链接：$DOWNLOAD_URL"
    
    # 下载最新文件
    wget "$DOWNLOAD_URL" -O "ddns-go_${VERSION}_linux_x86_64.tar.gz"
    
    # 检查下载是否成功
    if [[ ! -f "ddns-go_${VERSION}_linux_x86_64.tar.gz" ]]; then
        echo "文件下载失败。"
        exit 1
    fi
    
    # 解压文件
    tar -xzf "ddns-go_${VERSION}_linux_x86_64.tar.gz"
    
    # 移动并重命名文件到 /usr/local/bin/ 目录
    mv ddns-go /usr/local/bin/ddns-go
    
    # 设置权限为755
    chmod 755 /usr/local/bin/ddns-go
    
    echo "DDNS-Go安装完成，已放置在/usr/local/bin/并赋予执行权限。"
    
    # 创建systemd服务文件
    echo "[Unit]
Description=DDNS-Go Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ddns-go
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/ddns-go.service

    echo "Systemd服务文件创建完成。"

    # 重新加载systemd配置
    systemctl daemon-reload

    # 启动DDNS-Go服务
    systemctl start ddns-go
    
    # 设置DDNS-Go为开机自启
    systemctl enable ddns-go
    
    echo "DDNS-Go服务已启动并设置为开机自启。"

    # 删除下载的文件
    rm -f "ddns-go_${VERSION}_linux_x86_64.tar.gz"
    echo "已删除下载的压缩包文件。"
fi
