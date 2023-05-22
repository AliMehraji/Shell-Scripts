#! /bin/bash

set -ex 

apt install shadowsocks-libev simple-obfs -y 

read -p "External SERVER IP: " EXIP
read -p "External SERVER PORT: " EXPORT
read -sp "Password: " PASSWORD



cat << EOF >> /etc/shadowsocks-libev/config-obfs.json
{
    "server":"$EXIP",
    "server_port":$EXPORT,
    "local_port":1080,
    "password":"$PASSWORD",
    "timeout":60,
    "method":"chacha20-ietf-poly1305",
    "workers": 4,
    "mode":"tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http;obfs-host=www.google.com;fast-open",
    "fast_open":true,
    "reuse_port": true
}
EOF

sed -i 's/config.json/config-obfs.json/g' /etc/default/shadowsocks-libev

systemctl start shadowsocks-libev.service && systemctl enable shadowsocks-libev.service
