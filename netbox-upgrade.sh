#!/bin/bash -e




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




#OLD_VER=2.8.9
#NEW_VER=2.9.0

OLD_VER=$1
NEW_VER=$2



wget https://github.com/netbox-community/netbox/archive/refs/tags/v$NEW_VER.tar.gz -O /root/v$NEW_VER.tar.gz


pip install --upgrade pip

tar xvfz /root/v$NEW_VER.tar.gz

cp netbox-$OLD_VER/netbox/netbox/configuration.py netbox-$NEW_VER/netbox/netbox/
cp netbox-$OLD_VER/gunicorn_config.py netbox-$NEW_VER/gunicorn_config.py
cp netbox-$OLD_VER/netbox/netbox/ldap_config.py netbox-$NEW_VER/netbox/netbox/ldap_config.py
cp netbox-$OLD_VER/gunicorn.py netbox-$NEW_VER

rm netbox
ln -s netbox-$NEW_VER netbox

cat >> /opt/netbox/local_requirements.txt << EOF 
django-auth-ldap
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
set -x
cp -R  /opt/netbox-$OLD_VER/netbox/media /opt/netbox-$NEW_VER/netbox/
set +x
if [[ $? -ne 0 ]]; then
        echo "FAILED to copy media files, please do this manualy"
else
        echo "Media files copied OK"
fi
chown -R netbox:netbox /opt/netbox/netbox/media
ls -lh /opt/netbox/netbox/media