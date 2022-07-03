#!/bin/bash -e

alternatives --set python /usr/bin/python3.9
alternatives --set python3 /usr/bin/python3.9
source /opt/netbox/venv/bin/activate

if [ -z "$1" ]
then
      echo "You need to provide old version as 1st argument"
      exit 1
fi

if [ -z "$2" ]
then
      echo "You need to provide new version as 2nd argument"
      exit 1
fi


OLD_VER=$1
NEW_VER=$2

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [[ ! -f /root/v$NEW_VER.tar.gz ]]; then 
        wget https://github.com/netbox-community/netbox/archive/refs/tags/v$NEW_VER.tar.gz -O /root/v$NEW_VER.tar.gz
fi

pip install --upgrade pip

tar xvfz /root/v$NEW_VER.tar.gz

cp netbox-$OLD_VER/netbox/netbox/configuration.py netbox-$NEW_VER/netbox/netbox/
if [[ -f netbox-$OLD_VER/gunicorn_config.py ]]; then 
        cp netbox-$OLD_VER/gunicorn_config.py netbox-$NEW_VER/gunicorn_config.py
fi
if [[ -f netbox-$OLD_VER/netbox/netbox/ldap_config.py ]]; then  
        cp netbox-$OLD_VER/netbox/netbox/ldap_config.py netbox-$NEW_VER/netbox/netbox/ldap_config.py
fi

cp netbox-$OLD_VER/gunicorn.py netbox-$NEW_VER

rm netbox
ln -s netbox-$NEW_VER netbox

cat > /opt/netbox/local_requirements.txt << EOF 
django-auth-ldap
# netbox-dns
# netbox-topology-views 
EOF


cd netbox-$NEW_VER
./upgrade.sh

echo modifying systemd files
sed -i "s/$OLD_VER/$NEW_VER/g" /etc/systemd/system/netbox.service 
sed -i "s/$OLD_VER/$NEW_VER/g" /etc/systemd/system/netbox-rq.service

echo reloading systemd
systemctl daemon-reload

echo restarting netbox
systemctl restart netbox netbox-rq


echo "Moving device images"
#set -x
cp -R  /opt/netbox-$OLD_VER/netbox/media /opt/netbox-$NEW_VER/netbox/
#set +x
if [[ $? -ne 0 ]]; then
        echo -e "${RED}FAILED to copy media files, please do this manualy $NC"
else
        echo -e  "${GREEN}Media files copied OK $NC"
fi
chown -R netbox:netbox /opt/netbox/netbox/media
ls -lh /opt/netbox/netbox/media