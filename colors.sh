#!/bin/bash

#export PS1='\[\e]0;\u@\h: \w\a\]\[\e]0;\u@\h: \w\a\]\[\]\[\033[38;5;11m\]\u\[\]\[\033[38;5;13m\]@\[\]\[\033[38;5;11m\]\h\[\]\[\]\[\033[38;5;15m\]:\[\]\[\]\[\033[38;5;13m\][\[\]\[\]\[\033[38;5;10m\]\w\[\]\[\]\[\033[38;5;13m\]]\[\]\[\]\[\033[38;5;6m\]:\[\]\[\033[38;5;15m\] \[\]'


declare -A colors=(['red']='\e[31m' ['green']='\e[32m' ['yellow']='\e[33m' ['blue']='\e[34m' ['magenta']='\e[35m' ['cyan']='\e[36m' \
                [light_red]='\e[91m' ['light_green']='\e[92m' [light_yellow]='\e[93m' [light_blue]='\e[94m'\
                [bold]='\e[1m' ['no_color']='\033[0m' [bold_green]='\e[1;\e[32m' [bold_white]='\e[1;\e[97m'  )

_echo() {
       echo -e "${colors[$2]}${1}${colors[no_color]}"
}

_echo_yes() {
    echo -e "[${colors['green']}✓${colors[no_color]}]"
}

_echo_no(){
    echo -e "[${colors['red']}✗${colors[no_color]}]"
}


for color in red green yellow blue magenta cyan bold light_red light_green light_yellow light_blue bold_green bold_white; do 
    _echo $color $color
done


# echo "[✓]"
# echo "[✗]"