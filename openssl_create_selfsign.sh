#!/bin/bash

err_exit(){
    echo "$1"
    exint $2
}

[ -z "$1" ] && err_exit "Provide a domain name" 130


dest_path="/tmp"
tls_domain="$1"

key_path="$dest_path/$tls_domain.key"
crt_path="$dest_path/$tls_domain.crt"
csr_path="$dest_path/$tls_domain.csr"

sudo openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout "${key_path}" -out "${crt_path}" \
    -subj "/CN=$dest_domain/O=default/C=XX" \
    -addext 'extendedKeyUsage=1.3.6.1.5.5.7.3.1'
