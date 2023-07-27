#!/bin/bash


default_iface=$(ip --json  r l  | jq -r '.[] | select(.dst == "default").dev')
primary_ip=$(ip --json -4 a l "$default_iface"  | jq -r  ".[0].addr_info[0].local")
remote_port="56777"
local_port="6000"
destination="83.97.79.7:$remote_port"
echo "Primary ip: $primary_ip"


# differentiate ssh for snowflake nodes 
# mark 100 == client
cat <<EOF
iptables -t mangle -A PREROUTING -d "$primary_ip" -m tcp -p tcp --dport $local_port -m conntrack --ctstate NEW -m comment --comment "Snowflake client" -j MARK --set-mark 100
iptables -t nat -A PREROUTING -p tcp -m mark --mark 100 -m comment --comment "Snowflake client" -j DNAT --to-destination $destination
iptables -t nat -A POSTROUTING -m mark --mark 100 -m comment --comment "Snowflake client" -j SNAT --to-source "$primary_ip"
iptables -I FORWARD 1 -p tcp --syn --dport $remote_port -m conntrack --ctstate NEW -m  comment --comment "Snowflake client" -j ACCEPT
iptables -I FORWARD 2 -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -m  comment --comment "Snowflake client" -j ACCEPT

EOF

