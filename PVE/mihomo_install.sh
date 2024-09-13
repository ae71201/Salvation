#!/bin/bash

# 1. 获取最新版本号（compatible版本）
latest_version=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | grep -oP '"tag_name": "\K(.*?)(?=")')
echo "最新版本号为: $latest_version"

# 2. 下载最新的 compatible 版本文件
download_url="https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/${latest_version}/mihomo-linux-amd64-compatible-${latest_version}.gz"
wget $download_url -O /tmp/mihomo.gz

# 3. 使用gzip解压文件
gzip -d /tmp/mihomo.gz

# 4. 移动到/usr/local/bin
mv /tmp/mihomo /usr/local/bin/mihomo

# 5. 给与权限755
chmod 755 /usr/local/bin/mihomo

# 完成
echo "mihomo已安装并设置好权限。"
