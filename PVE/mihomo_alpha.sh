#!/bin/bash

# 使用GitHub API获取最新的alpha版本信息
response=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases)

# 从API响应中提取alpha版本文件名
alpha_version=$(echo "$response" | grep -oP '(?<=mihomo-linux-amd64-compatible-alpha-)[a-f0-9]+(?=\.gz)' | head -n 1)

# 检查是否成功获取到版本号
if [[ -z "$alpha_version" ]]; then
  echo "获取alpha版本号失败，请检查GitHub页面或网络连接。"
  exit 1
else
  echo "成功获取版本号: alpha-$alpha_version"
fi

# 构建下载链接并加上GitHub代理加速
github_proxy="https://mirror.ghproxy.com/"
download_url="${github_proxy}https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-amd64-compatible-alpha-$alpha_version.gz"

# 使用wget下载文件
wget $download_url -O /tmp/mihomo.gz

# 检查下载是否成功
if [[ $? -ne 0 ]]; then
  echo "文件下载失败，请检查下载链接或网络连接。"
  exit 1
else
  echo "文件成功下载到 /tmp/mihomo.gz"
fi

# 解压文件
gunzip /tmp/mihomo.gz

# 重命名并移动到 /usr/local/bin/，给予权限
mv /tmp/mihomo /usr/local/bin/mihomo
chmod 755 /usr/local/bin/mihomo

# 输出最终信息
echo "mihomo已成功安装到 /usr/local/bin/，版本: alpha-$alpha_version"