# differentiate ssh for snowflake nodes 
# mark 100 == client
iptables -t mangle -A PREROUTING -d 91.92.109.44 -m tcp -p tcp --dport 6000 -m conntrack --ctstate NEW -m comment --comment "Snowflake client" -j MARK --set-mark 100
iptables -t nat -A PREROUTING -p tcp -m mark --mark 100 -m comment --comment "Snowflake client" -j DNAT --to-destination 83.97.79.7:56777
iptables -t nat -A POSTROUTING -m mark --mark 100  -m  comment --comment "Snowflake client" -j SNAT --to-source 91.92.109.44
iptables -I FORWARD 1 -p tcp --syn --dport 56777 -m conntrack --ctstate NEW -m  comment --comment "Snowflake client" -j ACCEPT
iptables -I FORWARD 2 -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -m  comment --comment "Snowflake client" -j ACCEPT


