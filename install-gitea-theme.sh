#!/bin/bash
 
mkdir -p /var/lib/gitea/custom/public/css
cd /var/lib/gitea/custom/public/css
wget https://raw.githubusercontent.com/Jieiku/theme-dark-arc-gitea/main/theme-dark-arc.css
chown -R git:git /var/lib/gitea/custom

grep -q  '\[ui\]' /etc/gitea/app.ini 
if [[ $? -eq 0 ]]; then 
    echo "There are allready configured themes. Fix manualy"
else
echo "Setting up /etc/gitea/app.ini"
cat >> /etc/gitea/app.ini >> EOF
[ui]
DEFAULT_THEME = dark-arc
THEMES = gitea,dark-arc
EOF
systemctl restart gitea
fi