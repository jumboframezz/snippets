#!/bin/bash
# This sctipt checks if outbound IP is changed and sends sms
# written 26-June-2023 <lgeorgiedff@gmail.com>

verbose=0
send_sms(){
echo "$1" \
    |mail -s "Current IP sent from .55 " 359885563226@sms.mtel.net
}

real_ip="77.85.34.154"
current_ip=$(curl -s ifconfig.io) \
    || current_ip="Connectivity failed"

if [[ $real_ip != "$current_ip" ]]; then 
    send_sms "$current_ip"
else
    [ $verbose -eq 1 ] && echo "IP $current_ip is ok"
    logger "Check IP: $current_ip all green"
fi