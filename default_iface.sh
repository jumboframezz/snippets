#!/bin/bash

default_iface=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
echo "/proc/net: $default_iface"

route_entry=$(ip r l default)
default_gw=$(echo "$route_entry" | awk '{print $3}')
default_iface=$(echo "$route_entry" | awk '{print $5}')

echo "dev: $default_iface gw: $default_gw"

default_ip=$( ip  -4 --json a l "$default_iface"  | jq -r ".[0].addr_info[0].local" )
echo "Iface $default_iface IP: $default_ip"

ip --json r l default | jq -r ".[0].gateway"
ip --json  r l  | jq -r '.[] | select(.dst == "default").dev'