#!/bin/bash

declare -A colors=(['red']='\e[31m' ['green']='\e[32m' ['yellow']='\e[33m' ['blue']='\e[34m' ['magenta']='\e[35m' ['cyan']='\e[36m' \
                [light_red]='\e[91m' ['light_green']='\e[92m' [light_yellow]='\e[93m' [light_blue]='\e[94m'\
                [bold]='\e[1m' ['no_color']='\033[0m' [bold_green]='\e[1;\e[32m' [bold_white]='\e[1;\e[97m'  )

_echo() {
       echo -e "${colors[$2]}${1}${colors[no_color]}"
}

err_exit(){
    _echo "$1" red
    exit "${2:-0}" 
}

[ ! -d .git ] && err_exit "fatal: not a git repository : .git"
for remote in $( git remote -v | grep -o  '^\w*' |uniq); do 
    _echo "Pushing to remote $remote" green
    # git push "$remote"
done