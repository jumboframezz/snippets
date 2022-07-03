#!/bin/bash 

os_ver="/etc/os-release"
if [[ -f "${os_ver}" ]]; then 
    . "${os_ver}"
else 
    echo "Unknown OS. Please adjust ${os_ver}"
    exit 1
fi

packages="postgresql-server pwgen openldap-devel nginx gcc python39 python39-devel python39-pip libxml2-devel\
                   libxslt-devel libffi-devel libpq-devel openssl-devel redhat-rpm-config redis wget tar"


set -e
set -x 
case "${ID}" in
        "centos" | "rhel")
            echo "RHEL/Centos install"
            cat >  /etc/yum.repos.d/nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/$ID/\$releasever/\$basearch/
gpgcheck=0
enabled=1 
EOF
            if [[ ! -f "/etc/yum.repos.d/epel.repo " ]]; then 
                yum -y install epel-release
            fi 
            yum install -y $packages
            alternatives --set python /usr/bin/python3.9
        ;;
        "ubuntu")
            echo "ubuntu-like"
            # You need to add official repo from nginx here
            apt-get install -y "${packages}"
        ;;
        *)
            echo "Unsupported OS."
esac 
set +e
# alternatives --set python /usr/bin/python3.9
# alternatives --install /usr/bin/python python /usr/bin/python3.9 1
# alternatives --config python3

set -o xtrace               
postgresql-setup --initdb

cat > /var/lib/pgsql/data/pg_hba.conf << EOF
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            ident
host    replication     all             ::1/128                 ident
EOF

systemctl enable --now postgresql
pg_pass_file="/root/postgres_pass"
export new_pass=$( pwgen -y -s -r \'  32 1); echo $new_pass > $pg_pass_file
echo "Database password is written into $pg_pass_file. Keep it and remove the file."

sudo -u postgres psql << EOF
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD '$new_pass';
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;
EOF

# psql --username netbox --password --host localhost netbox -c "\q"; 
# if [[ $? -ne 0 ]]; then
#     echo "password authentication failed"
#     exit 1
# fi

systemctl enable --now redis
sleep 1s
redis-cli ping
if [[ $? -ne 0 ]]; then
    echo "Redis is not working"
    exit 1
fi
export PYTHON=/usr/bin/python3.9 
export PYTHON3=/usr/bin/python3.9 
pip3.9 install --upgrade pip

# export netbox_version="3.0.9"
export netbox_version="2.11.11"
wget https://github.com/netbox-community/netbox/archive/refs/tags/v$netbox_version.tar.gz
tar -xzf v$netbox_version.tar.gz -C /opt
ln -s /opt/netbox-$netbox_version/ /opt/netbox

groupadd --system netbox
adduser --system -g netbox netbox
mkdir -p  /opt/netbox/netbox/media/
chown --recursive netbox /opt/netbox/netbox/media/

cd /opt/netbox/netbox/netbox/
cp configuration.example.py configuration.py
netbox_config="/opt/netbox/netbox/netbox/configuration.py"
# export secret_key=$(PYTHON=/usr/bin/python3.9  /opt/netbox/netbox/generate_secret_key.py)
# export secret_key="'"$(PYTHON=/usr/bin/python3.9  /opt/netbox/netbox/generate_secret_key.py)"'"
export secret_key="'"$(PYTHON=/opt/netbox/venv/bin/python3.9 python3.9  /opt/netbox/netbox/generate_secret_key.py)"'"
#sed -i.bak "s/^SECRET_KEY.*/SECRET_KEY = $secret_key/g" /opt/netbox/netbox/netbox/configuration.py
echo "SECRET_KEY = $secret_key" >> $netbox_config
cat >> $netbox_config << EOF
DATABASE = {
    'NAME': 'netbox',         # Database name
    'USER': 'netbox',         # PostgreSQL username
    'PASSWORD': '$new_pass',  # PostgreSQL password
    'HOST': 'localhost',      # Database server
    'PORT': '',               # Database port (leave blank for default)
    'CONN_MAX_AGE': 300,      # Max database connection age
}
ALLOWED_HOSTS = ['*']
EOF
set +x
echo -e "\nedit $netbox_config: https://netbox.readthedocs.io/en/stable/installation/3-netbox/\n"
echo sleep for 10sec
sleep 10s
set -x 
sh -c "echo 'django-auth-ldap' >> /opt/netbox/local_requirements.txt"
sed -i.bak "s/REMOTE_AUTH_BACKEND.*/REMOTE_AUTH_BACKEND = 'netbox.authentication.LDAPBackend'/g" /opt/netbox/netbox/netbox/configuration.py 



python3=/usr/bin/python3.9 /opt/netbox/upgrade.sh
PYTHON3=/usr/bin/python3.9 source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox
set +x
echo -e "\n\nEnter superuser credentials for new installation:"
set -x
PYTHON3=/usr/bin/python3.9 /usr/bin/python3.9 manage.py createsuperuser
 
if [[ -f /opt/netbox/contrib/netbox-housekeeping.sh ]]; then 
    cp /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/
fi

for service in http https;  do
    firewall-cmd --permanent --add-service=$service
done
firewall-cmd --reload

export netbox_domain="netbox-prj.office.corp"
export redirect_url="https://$netbox_domain"
export nginx_resolver="10.40.0.4"
export ssl_dir="/etc/pki/tls"
export server_crt="$ssl_dir/$netbox_domain.crt"
export server_key="$ssl_dir/private/$netbox_domain.key"
export server_csr="$ssl_dir/private/$netbox_domain.csr"

sudo openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout $server_key -out $server_crt  -subj "/C=BG/ST=SOF/L=Sof/O=office/CN=$netbox_domain" \
                -addext "subjectAltName = DNS:$netbox_domain" 

cat > /etc/nginx/conf.d/netbox.conf << EOF
server {
        listen 443 ssl http2;

        server_name  $netbox_domain;
        root         /usr/share/nginx/html;

        ssl_certificate $server_crt;
        ssl_certificate_key $server_key;
        #ssl_dhparam /etc/ssl/certs/dhparam.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_session_cache shared:SSL:50m;
        ssl_session_timeout  1d;
        ssl_session_tickets off;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        add_header Strict-Transport-Security max-age=15768000;

        # OCSP Stapling ---
        # fetch OCSP records from URL in ssl_certificate and cache them
        ssl_stapling on;
        ssl_stapling_verify on;

        ## verify chain of trust of OCSP response using Root CA and Intermediate certs
        ## ssl_trusted_certificate /etc/ssl/$netbox_domain.chain;

        resolver $nginx_resolver;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
       
        ## netbox config
        location /static/ {
                alias /opt/netbox/netbox/static/;
        }

        location / {
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header        X-Real_IP       \$remote_addr;
                proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header        X-NginX-Proxy   true;
                proxy_set_header        Host            \$http_host;
                proxy_set_header        Upgrade         \$http_upgrade;
                proxy_pass_header       Set-Cookie;
        }
        
        ## /netbox config

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
EOF
## Allow proxy
setsebool httpd_can_network_connect 1 -P
## add 8081 port in selinux to allow connection
ssemanage port -a -t http_port_t -p tcp 8081

cp -f /etc/nginx/nginx.conf /root/nginx.conf.org

sed -i "s/^server_name  _;/server_name $netbox_domain;/1" /etc/nginx/nginx.conf
sed -i "/^server_name.*/a  return 301 $redirect_url;" /etc/nginx/nginx.conf

systemctl enable --now nginx
cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py

cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now netbox netbox-rq

systemctl status netbox.service
systemctl status netbox netbox-rq


#  sed -i.bak "/^server.*/d" /etc/ntp.conf && echo -e "server 10.27.3.4\nserver 10.40.3.4" >> /etc/ntp.conf &&\
#  systemctl restart ntpd &&  ntpstat 

# Replicating database
# su  postgres -
# pg_dump netbox > netbox.sql
# sudo -u postgres pg_dump netbox > netbox-$curtime.sql
# psql -c 'drop database netbox'
# psql -c 'create database netbox'
# psql netbox < netbox.sql
# systemctl restart netbox netbox-rq