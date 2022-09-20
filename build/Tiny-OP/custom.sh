#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default

# 添加第三方软件包
git clone https://github.com/authon/authon-openwrt-hub.git -b 18.06 package/authon-openwrt-hub
src-git helloworld https://github.com/fw876/helloworld
src-git passwall https://github.com/xiaorouji/openwrt-passwall

# 更新并安装源
./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/v2ray-plugin
rm -rf feeds/packages/net/haproxy
# rm -rf package/lean/luci-app-sfe
# rm -rf package/lean/luci-app-flowoffload
# rm -rf package/lean/luci-app-turboacc

# 自定义定制选项
ZZZ="package/lean/default-settings/files/zzz-default-settings"
#
sed -i 's#192.168.1.1#10.10.10.1#g' package/base-files/files/bin/config_generate                     # 定制默认IP
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' $ZZZ                                                        # 取消系统默认密码
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Authon-WRT'" $ZZZ                   # 修改主机名称为OpenWrt-X86
sed -i "s/OpenWrt /Authon build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ                      # 增加自己个性名称
# sed -i 's/PATCHVER:=5.4/PATCHVER:=4.19/g' target/linux/x86/Makefile                                # 修改内核版本为4.19
# sed -i "/uci commit luci/i\uci set luci.main.mediaurlbase=/luci-static/atmaterial_red" $ZZZ        # 设置默认主题(如果编译可会自动修改默认主题的，有可能会失效)

# ================================================
# sed -i 's#192.168.1.1#10.10.10.1#g' package/base-files/files/bin/config_generate #定制默认IP
# sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings #取消系统默认密码
# sed -i 's#max-width:200px#max-width:1000px#g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm #修改首页样式
# sed -i 's#max-width:200px#max-width:1000px#g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index_x86.htm #修改X86首页样式
# sed -i 's#option commit_interval 24h#option commit_interval 10m#g' feeds/packages/net/nlbwmon/files/nlbwmon.config               # 修改流量统计写入为10分钟
# sed -i 's#option database_directory /var/lib/nlbwmon#option database_directory /etc/config/nlbwmon_data#g' feeds/packages/net/nlbwmon/files/nlbwmon.config  # 修改流量统计数据存放默认位置
# sed -i 's#interval: 5#interval: 1#g' package/lean/luci-app-wrtbwmon/htdocs/luci-static/wrtbwmon.js               # wrtbwmon默认刷新时间更改为1秒
# echo -e '\n\nmsgid "This will delete the database file. Are you sure?"\nmsgstr "这将删除数据库文件, 你确定吗? "' >> package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po  # wrtbwmon流量统计
# sed -i 's@%D %V, %C@%D %V, %C Lienol_x86_64@g' package/base-files/files/etc/banner #自定义banner显示
# sed -i 's@e5effd@f8fbfe@g' package/dbone-update/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调
# sed -i 's#223, 56, 18, 0.04#223, 56, 18, 0.02#g' package/dbone-update/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调
#创建自定义配置文件 - Lean_x86_64

cd $WORKPATH
touch ./.config

#
# ========================固件定制部分========================
# 

# 
# 如果不对本区块做出任何编辑, 则生成默认配置固件. 
# 

# 以下为定制化固件选项和说明:
#

#
# 有些插件/选项是默认开启的, 如果想要关闭, 请参照以下示例进行编写:
# 
#          =========================================
#         |  # 取消编译VMware镜像:                   |
#         |  cat >> .config <<EOF                   |
#         |  # CONFIG_VMDK_IMAGES is not set        |
#         |  EOF                                    |
#          =========================================
#

# 
# 以下是一些提前准备好的一些插件选项.
# 直接取消注释相应代码块即可应用. 不要取消注释代码块上的汉字说明.
# 如果不需要代码块里的某一项配置, 只需要删除相应行.
#
# 如果需要其他插件, 请按照示例自行添加.
# 注意, 只需添加依赖链顶端的包. 如果你需要插件 A, 同时 A 依赖 B, 即只需要添加 A.
# 
# 无论你想要对固件进行怎样的定制, 都需要且只需要修改 EOF 回环内的内容.
# 

# 编译x64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF

# 设置固件大小:
cat >> .config <<EOF
CONFIG_TARGET_KERNEL_PARTSIZE=16
CONFIG_TARGET_ROOTFS_PARTSIZE=800
EOF

# 固件压缩:
cat >> .config <<EOF
CONFIG_TARGET_IMAGES_GZIP=y
EOF

# 编译UEFI固件:
cat >> .config <<EOF
CONFIG_EFI_IMAGES=y
EOF

## IPv6支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_dnsmasq_full_dhcpv6 is not set
# CONFIG_PACKAGE_ipv6helper  is not set
# EOF

# dnsmasq启用
# cat >> .config <<EOF
# CONFIG_PACKAGE_dnsmasq_full is not set
# CONFIG_PACKAGE_dnsmasq_full_ipset is not set
# CONFIG_PACKAGE_kmod-ipt-ipset is not set
# # CONFIG_PACKAGE_kmod-sched-ipset is not set
# CONFIG_PACKAGE_ipset is not set
# # CONFIG_PACKAGE_ipset-dns is not set
# CONFIG_PACKAGE_libipset is not set
# EOF

# IPv6支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_dnsmasq_full_dhcpv6 is not set
# CONFIG_PACKAGE_ipv6helper is not set
# EOF

# 多文件系统支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-fs-nfs=y
# CONFIG_PACKAGE_kmod-fs-nfs-common=y
# CONFIG_PACKAGE_kmod-fs-nfs-v3=y
# CONFIG_PACKAGE_kmod-fs-nfs-v4=y
# CONFIG_PACKAGE_kmod-fs-ntfs=y
# CONFIG_PACKAGE_kmod-fs-squashfs=y
# EOF

# USB3.0支持:
# cat >> .config <<EOF
# # CONFIG_PACKAGE_kmod-usb-ohci=y
# CONFIG_PACKAGE_kmod-usb-ohci-pci=y
# CONFIG_PACKAGE_kmod-usb2=y
# CONFIG_PACKAGE_kmod-usb2-pci=y
# CONFIG_PACKAGE_kmod-usb3=y
# EOF

# 第三方插件选择:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-oaf=n #应用过滤
# CONFIG_PACKAGE_luci-app-openclash=n #OpenClash
# CONFIG_PACKAGE_luci-app-serverchan=n #微信推送
CONFIG_PACKAGE_luci-app-eqos=y #IP限速
# CONFIG_PACKAGE_luci-app-smartdns=n #smartdns服务器
# CONFIG_PACKAGE_luci-app-adguardhome=n #ADguardhome
EOF

# ShadowsocksR插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus=y
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=y
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Socks=y
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray=y
EOF

# Helloword插件:
CONFIG_PACKAGE_luci-app-vssr=y

# Passwall插件2:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-passwall=y
# CONFIG_PACKAGE_naiveproxy=y
CONFIG_PACKAGE_chinadns-ng=y
# CONFIG_PACKAGE_brook=y
CONFIG_PACKAGE_trojan-go=y
CONFIG_PACKAGE_xray-plugin=y
CONFIG_PACKAGE_shadowsocks-rust-sslocal=y
EOF

# Turbo ACC 网络加速:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-turboacc=y
# luci-app-turboacc依赖
CONFIG_PACKAGE_dnsproxy=y
CONFIG_PACKAGE_dnsforwarder=y
EOF

# 常用LuCI插件:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-adbyby-plus=y #adbyby去广告
CONFIG_PACKAGE_luci-app-webadmin=y #Web管理页面设置
CONFIG_PACKAGE_luci-app-ddns=y #DDNS服务
CONFIG_DEFAULT_luci-app-vlmcsd=y #KMS激活服务器
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-upnp=y #通用即插即用UPnP(端口自动转发)
CONFIG_PACKAGE_luci-app-accesscontrol=y #上网时间控制
CONFIG_PACKAGE_luci-app-wol=y #网络唤醒
# CONFIG_PACKAGE_luci-app-frpc=n #Frp内网穿透
# CONFIG_PACKAGE_luci-app-nlbwmon=n #宽带流量监控
# CONFIG_PACKAGE_luci-app-wrtbwmon=n #实时流量监测
# CONFIG_PACKAGE_luci-app-sfe=n #高通开源的 Shortcut FE 转发加速引擎
# CONFIG_PACKAGE_luci-app-flowoffload=n #开源 Linux Flow Offload 驱动
CONFIG_PACKAGE_luci-app-arpbind=y #IP/MAC绑定
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-ntpc=y
# CONFIG_PACKAGE_luci-app-netdata is not set #使用监控（日志报错不启用）
CONFIG_PACKAGE_luci-app-fileassistant=y
CONFIG_PACKAGE_luci-app-filebrowser=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-ramfree=y #内存释放
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-poweroff=y #关机（增加关机功能）
CONFIG_PACKAGE_luci-app-control-mia=y #时间控制
CONFIG_PACKAGE_luci-app-control-timewol=y #定时唤醒
CONFIG_PACKAGE_luci-app-control-webrestriction=y #访问限制
CONFIG_PACKAGE_luci-app-control-weburl=y #网址过滤
# CONFIG_PACKAGE_luci-app-haproxy-tcp is not set #Haproxy负载均衡
# CONFIG_PACKAGE_luci-app-diskman is not set #磁盘管理磁盘信息
# CONFIG_PACKAGE_luci-app-transmission is not set #TR离线下载
# CONFIG_PACKAGE_luci-app-qbittorrent is not set #QB离线下载
# CONFIG_PACKAGE_luci-app-amule is not set #电驴离线下载
# CONFIG_PACKAGE_luci-app-xlnetacc is not set #迅雷快鸟
# CONFIG_PACKAGE_luci-app-zerotier is not set #zerotier内网穿透
# CONFIG_PACKAGE_luci-app-hd-idle is not set #磁盘休眠
# CONFIG_PACKAGE_luci-app-unblockmusic is not set #解锁网易云灰色歌曲
# CONFIG_PACKAGE_luci-app-airplay2 is not set #Apple AirPlay2音频接收服务器
# CONFIG_PACKAGE_luci-app-music-remote-center is not set #PCHiFi数字转盘遥控
# CONFIG_PACKAGE_luci-app-usb-printer is not set #USB打印机
# CONFIG_PACKAGE_luci-app-sqm is not set #SQM智能队列管理
# CONFIG_PACKAGE_luci-app-uugamebooster=n #UU游戏加速器
CONFIG_PACKAGE_luci-app-jd-dailybonus=y #京东签到
CONFIG_PACKAGE_luci-app-dockerman=n #Docker管理
CONFIG_PACKAGE_luci-app-wireguard=n #wireguard端
#
# VPN相关插件(禁用):
#
# CONFIG_PACKAGE_luci-app-v2ray-server is not set #V2ray服务器
# CONFIG_PACKAGE_luci-app-pptp-server is not set #PPTP VPN 服务器
# CONFIG_PACKAGE_luci-app-ipsec-vpnd is not set #ipsec VPN服务
# CONFIG_PACKAGE_luci-app-openvpn-server is not set #openvpn服务
# CONFIG_PACKAGE_luci-app-softethervpn is not set #SoftEtherVPN服务器
#
#
# 文件共享相关(禁用):
#
CONFIG_PACKAGE_luci-app-minidlna=n #miniDLNA服务
CONFIG_PACKAGE_luci-app-vsftpd=n #FTP 服务器
CONFIG_PACKAGE_luci-app-samba=n #网络共享
CONFIG_PACKAGE_autosamba=n #网络共享
CONFIG_PACKAGE_samba36-server=n #网络共享
EOF

# LuCI主题:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-atmaterial=y
CONFIG_PACKAGE_luci-theme-netgear=y
CONFIG_PACKAGE_luci-theme-edge=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-argon-dark-mod=y
CONFIG_PACKAGE_luci-theme-argon-light-mod=y
CONFIG_PACKAGE_luci-theme-bootstrap-mod=y
CONFIG_PACKAGE_luci-theme-netgear-mc=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
# CONFIG_PACKAGE_screen=y
# CONFIG_PACKAGE_tree=y
# CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_node=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_snmpd=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libcap-bin=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_iptables-mod-extra=y
CONFIG_PACKAGE_vsftpd=y
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_qemu-ga=y
EOF

# 其他软件包:
cat >> .config <<EOF
CONFIG_HAS_FPU=y
EOF

# 取消编译VMware镜像以及镜像填充 (不要删除被缩进的注释符号):
cat >> .config <<EOF
CONFIG_TARGET_IMAGES_PAD=y
CONFIG_VMDK_IMAGES=y
EOF

# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd $HOME

# 配置文件创建完成
