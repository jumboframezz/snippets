#!/bin/bash

exec_command=/usr/local/scripts/check_home_ip.sh
service_file=check-ip.service

cat > /etc/systemd/system/$service_file <<EOF
[Unit]
Description=Check outbound IP address at startup
After=default.target

[Service]
Type=oneshot
ExecStart=$exec_command

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable $service_file