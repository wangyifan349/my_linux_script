# 1. 禁用APT每日更新计划
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
# 2. 注释掉APT源列表中的所有deb源以避免修改，防止更新
sudo sed -i 's/^deb/#deb/' /etc/apt/sources.list
# 3. 禁用Apport（Ubuntu错误报告工具），以阻止错误报告的自动发送
sudo systemctl stop apport.service
sudo systemctl disable apport.service
# 4. 编辑Apport配置文件以永久禁止错误报告
sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport
# 5. 禁用NetworkManager的远程链接识别，以避免连接到可能的远程管理系统
sudo sed -i 's/^dns=dnsmasq/#dns=dnsmasq/' /etc/NetworkManager/NetworkManager.conf
# 6. 禁用snapd服务，避免与snap相关的自动更新及遥感
sudo systemctl stop snapd.service
sudo systemctl disable snapd.service
# 7. 注释掉Ubuntu遥感服务配置以防止数据收集
sudo tee /etc/default/ubuntu-report <<EOF
enabled=0
EOF
# 8. 禁用未使用的远程桌面服务
sudo systemctl stop avahi-daemon.service
sudo systemctl disable avahi-daemon.service
# 9. 禁用自动安装已知不必要的驱动
sudo apt remove --purge ubuntu-drivers-common -y
# 10. 禁用Geoclue（地理位置服务）
sudo systemctl stop geoclue.service
sudo systemctl disable geoclue.service
# 11. 禁用modemmanager服务（如果不使用调制解调器）
sudo systemctl stop ModemManager.service
sudo systemctl disable ModemManager.service
# 12. 编辑Ubuntu Shopper Scope配置以防止搜索服务的远端交互
gsettings set com.canonical.Unity.Lenses remote-content-search 'none'
# 13. 禁用Plymouth（启动图形界面加载显示）
sudo systemctl stop plymouth-start.service
sudo systemctl disable plymouth-start.service
# 14. 禁用定期的Logrotate清理（可选）
sudo systemctl stop logrotate.timer
sudo systemctl disable logrotate.timer
# 15. 将定期更新消息设施（Unattended Upgrades）设置为手动
sudo dpkg-reconfigure -plow unattended-upgrades
# 16. 禁用Bluetooth服务（如果不需要使用蓝牙）
sudo systemctl stop bluetooth.service
sudo systemctl disable bluetooth.service
# 17. 禁用Cups服务（如果不需要打印服务）
sudo systemctl stop cups.service
sudo systemctl disable cups.service
# 18. 禁用多余的FirewallD服务（如果使用其他防火墙软件如ufw）
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service
# 19. 禁用Avahi服务（用于发现局域网中的设备，一般不需要）
sudo systemctl stop avahi-daemon.service
sudo systemctl disable avahi-daemon.service
# 20. 禁用Zeroconf服务（如果不使用自动化的本地网络配置）
sudo sed -i 's/^avahi/#avahi/' /etc/nsswitch.conf
# 21. 禁用自动挂载服务（如果不需要自动挂载外部设备）
sudo systemctl stop udisks2.service
sudo systemctl disable udisks2.service
# 22. 禁用网络时间同步服务（如果不需要自动校准时间频率）
sudo systemctl stop systemd-timesyncd.service
sudo systemctl disable systemd-timesyncd.service
# 23. 禁用Account Service（如果不需要用户账户管理服务）
sudo systemctl stop accounts-daemon.service
sudo systemctl disable accounts-daemon.service
# 24. 禁用动态主机配置协议（DHCP）客户端服务（如果静态IP配置）
sudo systemctl stop isc-dhcp-client.service
sudo systemctl disable isc-dhcp-client.service
# 25. 禁用系统日志记录服务（如果不需要或使用其他日志系统）
sudo systemctl stop rsyslog.service
sudo systemctl disable rsyslog.service
# 26. 禁用Tracker Miner服务（文件索引服务，比较耗资源）
sudo systemctl stop tracker-extract.service
sudo systemctl disable tracker-extract.service
# 27. 禁用Remote Desktop服务（如果不需要远程访问桌面）
sudo systemctl stop xrdp.service
sudo systemctl disable xrdp.service
# 28. 禁用Speech Dispatcher服务（如不需要语音服务）
sudo systemctl stop speech-dispatcher.service
sudo systemctl disable speech-dispatcher.service

# 29. 禁用各种调试和开发相关的服务（除非需要开发）
sudo systemctl stop debug-shell.service
sudo systemctl disable debug-shell.service

# 30. 禁用Mlocate服务的数据库自动更新（如mcurrent不使用）
sudo systemctl stop mlocate-updatedb.timer
sudo systemctl disable mlocate-updatedb.timer



# =======================
# 禁用APT自动更新
# =======================

# 禁用定期更新包列表
echo 'APT::Periodic::Update-Package-Lists "0";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades

# 禁用未经监督的自动升级
echo 'APT::Periodic::Unattended-Upgrade "0";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades

# 禁止自动清理不使用的包
echo 'APT::Periodic::AutocleanInterval "0";' | sudo tee /etc/apt/apt.conf.d/10periodic

# 禁用自动下载可升级软件包
echo 'APT::Periodic::Download-Upgradeable-Packages "0";' | sudo tee -a /etc/apt/apt.conf.d/10periodic

# =======================
# 禁用错误报告和数据收集
# =======================

# 禁用Apport以避免错误报告自动发送
echo 'enabled=0' | sudo tee /etc/default/apport

# 禁用Ubuntu Report以防止数据收集
echo '[settings]' | sudo tee /etc/ubuntu-report/config.conf > /dev/null
echo 'ReportMetrics=false' | sudo tee -a /etc/ubuntu-report/config.conf > /dev/null

# =======================
# 禁用与远程和网络相关的行为
# =======================

# 禁用NetworkManager的连接检查以减少不必要的网络请求
# 在原有文件基础上追加连接设置
sudo bash -c 'echo "[connectivity]" >> /etc/NetworkManager/NetworkManager.conf'
sudo bash -c 'echo "uri=" >> /etc/NetworkManager/NetworkManager.conf'

# 禁用远程搜索功能
gsettings set com.canonical.Unity.Lenses remote-content-search 'none'

# =======================
# 其他配置
# =======================

# 禁用Motd，防止SSH登陆时的系统消息提示
sudo sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news

# 禁用Canonical Livepatch服务（如果已经安装）
sudo snap disable canonical-livepatch

# 设置APT以阻止自动建议的软件包（禁用缓存和管道）
echo 'Acquire::http::No-Cache "true";' | sudo tee /etc/apt/apt.conf.d/99nocache
echo 'Acquire::http::Pipeline-Depth "0";' | sudo tee -a /etc/apt/apt.conf.d/99nocache

# 禁用自动计划的无人值守升级
echo 'exit 0' | sudo tee /etc/apt/apt.conf.d/99disable-unattended

# 禁止系统自动安装推荐的或建议的软件包
echo 'APT::Install-Recommends "0";' | sudo tee /etc/apt/apt.conf.d/99no-recommends
echo 'APT::Install-Suggests "0";' | sudo tee -a /etc/apt/apt.conf.d/99no-recommends

# 停用systemd维护的网络时间同步
sudo timedatectl set-ntp false


# 启用TCP BBR 拥塞控制算法以提高网络吞吐量和减少延迟
echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf

# 立即生效
sudo sysctl -p

# 验证BBR已启用
echo "当前启用的TCP拥塞控制算法："
sysctl net.ipv4.tcp_congestion_control

# 通过/proc查看BBR是否在运行
echo "BBR是否已启用："
lsmod | grep bbr

# 增加文件描述符限制以提高高负载时的稳定性
echo '* soft nofile 65535' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65535' | sudo tee -a /etc/security/limits.conf

# =============
# 安全性设置
# =============

# 禁用IPv6（如果不使用IPv6的话，可能减少攻击面）
echo 'net.ipv6.conf.all.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf

# 立即生效
sudo sysctl -p

# 防止syn攻击
echo 'net.ipv4.tcp_syncookies = 1' | sudo tee -a /etc/sysctl.conf

# 防止IP源路由（IP spoofing情况）
echo 'net.ipv4.conf.all.accept_source_route = 0' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.accept_source_route = 0' | sudo tee -a /etc/sysctl.conf

# 禁用IP转发功能以防止网络嗅探
echo 'net.ipv4.ip_forward = 0' | sudo tee -a /etc/sysctl.conf

# 设置IP地址防止伪造
echo 'net.ipv4.conf.all.rp_filter = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter = 1' | sudo tee -a /etc/sysctl.conf

# 禁用ICMP重定向
echo 'net.ipv4.conf.all.accept_redirects = 0' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.accept_redirects = 0' | sudo tee -a /etc/sysctl.conf

# 禁用发送ICMP重定向
echo 'net.ipv4.conf.all.send_redirects = 0' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.send_redirects = 0' | sudo tee -a /etc/sysctl.conf

# 立即应用所有sysctl设置
sudo sysctl -p


# =======================
# 安装常用工具
# =======================

# 安装GnuPG（PGP工具，用于加密和签名）
sudo apt install -y gnupg

# 安装VLC（多功能媒体播放器）
sudo apt install -y vlc

# 安装Git（版本控制系统）
sudo apt install -y git

# 安装cURL（命令行数据传输工具）
sudo apt install -y curl

# 安装Wget（命令行下载器）
sudo apt install -y wget

# 安装必备构建工具
sudo apt install -y build-essential

# 安装常用压缩工具
sudo apt install -y zip unzip

# =======================
# 安装数学运算库
# =======================

# 安装Python3及其基本数学库
sudo apt install -y python3 python3-pip
pip3 install numpy scipy matplotlib

# =======================
# 安装界面优化工具
# =======================

# 安装GNOME Tweaks（GNOME界面优化工具）
sudo apt install -y gnome-tweaks

# 安装桌面剪贴板管理工具
sudo apt install -y copyq

# 安装Htop（交互式进程查看器，替代top）
sudo apt install -y htop

# =======================
# 系统美化类工具
# =======================

# 安装字体管理工具
sudo apt install -y font-manager

# 安装Conky（桌面系统监视器）
sudo apt install -y conky







# 添加Nginx官方源及公钥
echo "deb http://nginx.org/packages/ubuntu/ $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
# 添加Node.js源及公钥
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
# 添加Docker源及公钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# 添加MongoDB源及公钥
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list


sudo apt update && sudo apt install -y wireshark tcpdump nmap net-tools traceroute iproute2 iputils-ping whois dnsutils  # Wireshark: 网络协议分析仪; tcpdump: 流量捕获; nmap: 网络探测与端口扫描; net-tools: 网络诊断工具; traceroute: 路径追踪; iproute2: 网络配置; iputils-ping: 连通性测试; whois: 域名查询; dnsutils: DNS查询工具
sudo bash -c 'cat > /etc/systemd/resolved.conf' << EOF
[Resolve]
DNS=1.1.1.1 8.8.8.8
DNSOverTLS=yes
Domains=~.
LLMNR=false
MulticastDNS=false
DNSSEC=no
Cache=no-negative=yes
EOF
sudo systemctl restart systemd-resolved
sudo systemctl enable systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
