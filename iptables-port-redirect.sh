#!/bin/bash

ip_forward_file="/etc/sysctl.d/50-ipforward.conf"

err_exit(){
    echo "$1"
    exit $2
}

[ -f /etc/os-release ] && . /etc/os-release \
    || err_exit "No /etc/os-release"


case "$ID" in 
    debian)
        !  dpkg -s jq > /dev/null && apt -y install jq
        ;;
    rocky)
        dnf -y install jq
        ;;
    *)
        err_exit "Unsupported distro" 131
        ;;
esac
[ ! -f $ip_forward_file ] && {
    echo "net.ipv4.ip_forward=1" > $ip_forward_file
    sysctl -p $ip_forward_file
}
remote_port="56777"
local_port="6000"
destination="192.158.72.68:$remote_port"

default_iface=$(ip --json  r l  | jq -r '.[] | select(.dst == "default").dev')
primary_ip=$(ip --json -4 a l "$default_iface"  | jq -r  ".[0].addr_info[0].local")
echo "Primary ip: $primary_ip"

# mark 100 == forwarded traffic
for table in nat mangle filter; do 
    iptables -F -t $table
    echo "$table flushed"
done    
set -x
iptables -P FORWARD DROP
#1
iptables -t mangle -I PREROUTING 1 -d "$primary_ip" -m tcp -p tcp --dport $local_port -m conntrack --ctstate NEW -m comment --comment "Client step 1" -j LOG    
iptables -t mangle -I PREROUTING 1 -d "$primary_ip" -m tcp -p tcp --dport $local_port -m conntrack --ctstate NEW -m comment --comment "Client step 1" \
    -j MARK --set-mark 100

# 2
iptables -t nat -A PREROUTING -p tcp -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport $local_port -m comment --comment "Client step 2" -j LOG
iptables -t nat -A PREROUTING -p tcp --dport $remote_port -m comment --comment "Client step 2" -j LOG
iptables -t nat -A FORWARD -p tcp --dport $local_port -m comment --comment "Client step 2" -j LOG
iptables -t nat -A FORWARD -p tcp --dport $remote_port -m comment --comment "Client step 2" -j LOG



iptables -t nat -A PREROUTING -p tcp --dport $local_port -m comment --comment "Client step 2" -j DNAT --to-destination $destination
iptables -t nat -A PREROUTING -p tcp --dport $remote_port -m comment --comment "Client step 2" -j DNAT --to-destination $destination

# 3.1 
iptables -t mangle -A FORWARD -m tcp -p tcp --dport 6000 -j LOG
iptables -t mangle -A FORWARD -m tcp -p tcp --dport 56777 -j LOG

# 3.2 
iptables -t mangle -A INPUT -m tcp -p tcp --dport 6000 -j LOG
iptables -t mangle -A INPUT -m tcp -p tcp --dport 56777 -j LOG


iptables -I FORWARD 1 -p tcp --syn --dport $remote_port -m mark --mark 100 -m conntrack --ctstate NEW -m  comment --comment "Client SYN forward" -j ACCEPT
iptables -I FORWARD 2 -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -m  comment --comment "Client forward" -j ACCEPT

# 4
iptables -t nat -I POSTROUTING 1 -m mark --mark 100 -m comment --comment "Snowflake client" -j SNAT --to-source "$primary_ip"


# iptables -t mangle -A INPUT -d "$primary_ip" --dport 6000 -j LOG



iptables -A INPUT -m tcp -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -m tcp -p tcp --dport 22 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD 2 -p tcp --dport $remote_port -j LOG --log-prefix='[netfilter]'
# iptables -P INPUT DROP
set +x
telnet 192.168.72.16  6000
# placeholder
