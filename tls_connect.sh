#!/bin/bash


declare -A colors=(['red']='\e[31m' ['green']='\e[32m' ['yellow']='\e[33m' ['blue']='\e[34m' ['magenta']='\e[35m' ['cyan']='\e[36m' \
                [light_red]='\e[91m' ['light_green']='\e[92m' [light_yellow]='\e[93m' [light_blue]='\e[94m'\
                [bold]='\e[1m' ['no_color']='\033[0m' [bold_green]='\e[1;\e[32m' [bold_white]='\e[1;\e[97m'  )

_echo() {
       echo -e "${colors[$2]}${1}${colors[no_color]}"
}

err_exit(){
    _echo "$1" red
    exit "${2:-0}" 
}

tls_domain=$1
tls_port=${2:-443}
# openssl s_client -showcerts -servername "$tls_domain" -connect "$tls_domain:$tls_port"  </dev/null

openssl s_client -showcerts -connect "$tls_domain:$tls_port" \
     </dev/null 2>/dev/null \
     | openssl x509 -outform PEM > /tmp/"$tls_domain".crt

crt_data=$( openssl x509 -text -noout -in "/tmp/$tls_domain".crt )
_echo "Certificate data" yellow

echo "${crt_data[@]}" | grep 'Subject:' 
echo "${crt_data[@]}" | grep 'Issuer:'
echo "${crt_data[@]}" | grep 'Not Before:'
echo "${crt_data[@]}" | grep ' Not After :'

echo 
set -x 
rm -rf "/tmp/$tls_domain".crt
set +x

# placeholder