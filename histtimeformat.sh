#!/bain/bash
dst=/etc/profile

# timedatectl set-timezone UTC
# export TZ="Europe/Sofia"
# export HISTTIMEFORMAT="%d-%b-%y %T "
# Color hint:
# MY_BASH_BLUE="\033[0;34m" #Blue
# MY_BASH_NOCOLOR="\033[0m"
# HISTTIMEFORMAT=$(echo -e ${MY_BASH_BLUE}[%F %T] $MY_BASH_NOCOLOR)

[ -f "$dst" ] && echo 'export HISTTIMEFORMAT="%d-%b-%y %T "' >> /etc/profile \
    || echo "$dst file not found"

