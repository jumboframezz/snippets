#!/bain/bash
dst=/etc/profile

# timedatectl set-timezone UTC
# export TZ="Europe/Sofia"
# export HISTTIMEFORMAT="%d-%b-%y %T "

[ -f "$dst" ] && echo 'export HISTTIMEFORMAT="%d-%b-%y %T "' >> /etc/profile \
    || echo "$dst file not found"

