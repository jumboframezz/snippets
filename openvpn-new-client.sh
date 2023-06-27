#!/bin/bash
# This generates new openvon client. Not tested 
err_exit(){
    echo "$1" && exit "$2"
}

client_name="t480-june"
dst_dir="/etc/openvpn/client/$client_name"
[ -d $dst_dir ] && err_exit "$dst_dir already exists."
mkdir -p $dst_dir
cd /etc/easy-rsa/ || return
./easyrsa build-client-full $client_name nopass && \
    cp -rp /etc/easy-rsa/pki/{ca.crt,issued/$client_name.crt,private/$client_name.key} $dst_dir

server_ip=$(dig lz1lgg.eu -4 +short)

cat <<EOF
client
tls-client
pull
dev tun
proto udp4
remote $server_ip  1194

data-ciphers AES-256-GCM 
# data-ciphers-fallback BF-CBC
auth SHA256
resolv-retry infinite
nobind
user nobody
group nobody
persist-key
persist-tun
key-direction 1
remote-cert-tls server
auth-nocache
# comp-lzo
verb 3
auth SHA512
tls-auth ta.key 1
ca /home/lucho/openvn-client/ca.crt
cert /home/lucho/openvn-client/client.crt
key /home/lucho/openvn-client/client.key

EOF