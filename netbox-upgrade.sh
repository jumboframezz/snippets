#!/bin/bash -e
# Netbox upgrade script
# Written 2019 lachezarg@nsogroup.com
# Modified 26-Oct-2022 lachezarg@nsogroup.com
# Modified 07 June 2022 lachezarg@nsogroup.com

declare -A colors=([red]='\e[31m' ["green"]='\e[32m' ['yellow']='\e[33m' ['blue']='\e[34m' ['magenta']='\e[35m' ['cyan']='\e[36m' ['no_color']='\033[0m')
_echo() {
       echo -e "${colors[${2}]}${1}${colors[no_color]}"
}

[ -z "$1" ] && color_echo "You need to provide old version as 1st argument" red && exit 130

[ -z "$2" ] && color_echo "You need to provide new version as 2nd argument" red && exit 130 

OLD_VER=$1
NEW_VER=$2

if [ -d netbox-$NEW_VER ]; then 
      color_echo "Destination already exists" red
      exit 128
fi
_echo "Stopping nginx" red
systemctl stop nginx


# download_url="https://github.com/netbox-community/netbox/archive/refs/tags/"
download_url="http://repos.office.corp/repository/netbox/"
[ ! -f /root/v$NEW_VER.tar.gz ] && \
      wget --no-check-certificate $download_url/v$NEW_VER.tar.gz -O /root/v$NEW_VER.tar.gz

pip install --upgrade pip

tar xvfz /root/v$NEW_VER.tar.gz

cp netbox-$OLD_VER/netbox/netbox/configuration.py netbox-$NEW_VER/netbox/netbox/
[ -f netbox-$OLD_VER/gunicorn_config.py ] && \
      cp netbox-$OLD_VER/gunicorn_config.py netbox-$NEW_VER/gunicorn_config.py
cp netbox-$OLD_VER/netbox/netbox/ldap_config.py netbox-$NEW_VER/netbox/netbox/ldap_config.py
cp netbox-$OLD_VER/gunicorn.py netbox-$NEW_VER

rm netbox
ln -s netbox-$NEW_VER netbox

cat >> /opt/netbox/local_requirements.txt << EOF 
django-auth-ldap
typing_extensions
nextbox-ui-plugin
EOF

cd netbox-$NEW_VER
./upgrade.sh

echo modifying systemd files
sed -i "s/$OLD_VER/$NEW_VER/g" /etc/systemd/system/netbox.service 
sed -i "s/$OLD_VER/$NEW_VER/g" /etc/systemd/system/netbox-rq.service

_echo 'reloading systemd' yellow
systemctl daemon-reload

_echo "Restarting netbox" green 
set -x;  systemctl restart netbox netbox-rq; set +x

if [[ -f /opt/netbox-$OLD_VER/netbox/media ]]; then 
      echo "Moving device images"
      #set -x
      cp -R  /opt/netbox-$OLD_VER/netbox/media /opt/netbox-$NEW_VER/netbox/
      #set +x
      if [[ $? -ne 0 ]]; then
            _echo "FAILED to copy media files, please do this manualy" red
      else
            _echo   "Media files copied OK" green
      fi
chown -R netbox:netbox /opt/netbox/netbox/media
ls -lh /opt/netbox/netbox/media

fi 

_echo "Starting nginx" red
systemctl start nginx


