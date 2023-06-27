#!/bin/bash
# This generates new openvon client. Not tested 
err_exit(){
    echo "$1"
    exit "$2"
}

client_name="t480-june"
dst_dir="/etc/openvpn/client/$client_name"
[ -d $dst_dir ] && err_exit "$dst_dir already exists."
mkdir -p $dst_dir
cd /etc/easy-rsa/ || return
./easyrsa build-client-full $client_name nopass && \
    cp -rp /etc/easy-rsa/pki/{ca.crt,issued/$client_name.crt,private/$client_name.key} $dst_dir