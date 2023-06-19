#!/bin/bash

## Set current_user to $1 if not specified current_user=$USER
    current_user=${1:-$USER}
    echo "Current user: $current_user"


## Assign a value foo to the $USER variable if doesn’t already have one:
    unset var1
    echo "${var1:=default_value}"


## Display error if var1 is not defined:
    unset var1
    echo "${var1?Error var1 is not defined}"


## Remove patterns in front:
    var1="/etc/resolv.conf"
    echo "${var1#/etc/}" 

    var1=https://ds01.domain.internal/ipa/ui/#/e/user/search/page=3
    echo "${var1#*/}"   # /ds01.domain.internal/ipa/ui/#/e/user/search/page=3
    echo "${var1##*/}"  # page=3


## Remove patterns in end:
    var1="bash-1.3.0.tar.gz"
    echo "${var1%.tar.gz}"

## Replace patterns
    var1="Use unix or die"
    echo "${var1/unix/linux}"

# nice way to make backup:
    file=/etc/resolv.conf
    cp "${file}" "${file/.conf/.conf.bak}"


## Slicing as in python
var1="0123456789"
echo "${var1:4}"
echo "${var1:4:2}"


## Get list of matching variable names
var1="Bus"
# shellcheck disable=SC2034
var2="Car"
# shellcheck disable=SC2034 
var3="Train" 
echo "${!var*}"


## Convert to upper to lower case or vice versa
name="lachezar"
echo "${name^}"
echo "${name^^}"
# Convert everything to lowercase
    dest="/HOME/Lucho/DaTA"
    echo "Actual path: ${dest,,}"
# Convert only first character to lowercase 
    src="HOME"
    echo "${src,}"
# Only convert first character in $dest if it is a capital ‘H’:
    dest="Home"
    echo "${dest,H}"
    dest="Fhome"
    echo "${dest,H}"


# placeholder
