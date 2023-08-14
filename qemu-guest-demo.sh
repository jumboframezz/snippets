#!/bin/bash
#  mkdir -p /var/lib/libvirt/qemu/channel/target
#  chown -R qemu:qemu /var/lib/libvirt/qemu/channel
# You need to add config bellow right after splice channel with virsh edit <domain>
# <channel type="unix">
#    <source mode="bind"/>
#    <target type="virtio" name="org.qemu.guest_agent.0"/>
# </channel>

# Then from hypervisor or remote:
# virsh qemu-agent-command ubuntu20-test '{"execute":"guest-network-get-interfaces"}' | jq
# virsh qemu-agent-command ubuntu20-test '{"execute":"guest-info"}' --pretty


# remote_pid=$(virsh qemu-agent-command ubuntu20-test  '{"execute": "guest-exec", "arguments": { "path": "route", "arg": [ "-n" ], "capture-output": true }}' \
#  | jq .return.pid)

# result=$( virsh qemu-agent-command ubuntu20-test  "{\"execute\": \"guest-exec-status\", \"arguments\": { \"pid\": $remote_pid }}" )

# echo $result | jq .return.exitcode
# echo $result | jq .return.exited
# out_data=$(echo $result | jq -r '.return."out-data"')

# echo $out_data | base64 -d 

# ip --json r l default | jq -r ".[0].gateway"


args='["-json", "r", "l", "default"]'
remote_pid=$(virsh qemu-agent-command ubuntu20-test   "{\"execute\": \"guest-exec\", \"arguments\": { \"path\": \"ip\", \"arg\": $args, \"capture-output\": true }}" \
    | jq .return.pid)

result=$( virsh qemu-agent-command ubuntu20-test  "{\"execute\": \"guest-exec-status\", \"arguments\": { \"pid\": $remote_pid }}" )

echo "$result" | jq .return.exitcode
echo "$result" | jq .return.exited
out_data=$(echo "$result" | jq -r '.return."out-data"')
default_route_line=$(echo "$out_data" | base64 -d)

echo "$default_route_line" | jq -r '.[] | select(.dst == "default").dev'
echo "$default_route_line" | jq -r '.[] | select(.dst == "default").gateway'