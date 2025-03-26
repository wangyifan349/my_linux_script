#!/bin/bash

# =======================
# 环境变量设置
# =======================

echo "配置环境变量... "

# 临时设置
export http_proxy="http://127.0.0.1:10809"
export https_proxy="http://127.0.0.1:10809"
export all_proxy="socks5://127.0.0.1:10808"

# 永久设置：将设置添加到 ~/.bashrc
echo 'export http_proxy="http://127.0.0.1:10809"' >> ~/.bashrc
echo 'export https_proxy="http://127.0.0.1:10809"' >> ~/.bashrc
echo 'export all_proxy="socks5://127.0.0.1:10808"' >> ~/.bashrc

# 使新设置立即生效
source ~/.bashrc

echo "环境变量配置完成。"

# =======================
# Proxychains 配置
# =======================

echo "配置 Proxychains..."

# 安装 proxychains4（如果尚未安装）
sudo apt update && sudo apt install -y proxychains4

# 使用 cat 写入 Proxychains 配置：设置代理为 SOCKS5
PROXYCHAINS_CONF="/etc/proxychains4.conf"
sudo bash -c "cat <<EOF > $PROXYCHAINS_CONF
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
# 使用 SOCKS5 类型的代理
socks5  127.0.0.1 10808
EOF"

echo "Proxychains 配置完成。"

# =======================
# Tsocks 配置
# =======================

echo "配置 Tsocks..."

# 安装 tsocks（如果尚未安装）
sudo apt update && sudo apt install -y tsocks

# 使用 cat 写入 Tsocks 配置
TSOCKS_CONF="/etc/tsocks.conf"
sudo bash -c "cat <<EOF > $TSOCKS_CONF
# /etc/tsocks.conf - tsocks 配置文件

server = 127.0.0.1
server_type = 5
server_port = 10808

# 排除本地网络，避免代理本地流量
local = 192.168.0.0/255.255.0.0
local = 127.0.0.0/255.0.0.0
EOF"

echo "Tsocks 配置完成。"

# =======================
# 代理测试
# =======================

echo "测试代理是否正确配置..."

# 使用 curl 测试
echo "使用 curl 通过 HTTP 代理测试获取 IP 地址..."
curl -x http://127.0.0.1:10809 http://ipinfo.io/ip

# 使用 proxychains + curl 测试
echo "使用 proxychains + curl 测试获取 IP 地址..."
proxychains4 curl http://ipinfo.io/ip

# 使用 tsocks + curl 测试
echo "使用 tsocks + curl 测试获取 IP 地址..."
tsocks curl http://ipinfo.io/ip

# 使用 wget 测试
echo "使用 wget 通过 HTTP 代理测试获取 IP 地址..."
wget -qO- --proxy=on --no-check-certificate --execute="http_proxy=http://127.0.0.1:10809" http://ipinfo.io/ip

echo "代理配置和测试完成。"
