#!/bin/bash
RED='\033[0;31m'
GREEN='\e[0;32;40m'
YELLOW="\e[0;33;40m"
NC='\033[0m' # No Color
not_inst="Not installed"
inst="Installed"

red_echo() {
       echo -e "${RED}${1}${NC}"
}

green_echo() {
       echo -e "${GREEN}${1}${NC}"
}

yellow_echo() {
       echo -e "${YELLOW}${1}${NC}"
}


check_redhat_installer() {
	if [[  "${VERSION_ID:0:1}" == "8" ]]; then 
		echo "dnf"
	else
		echo "yum"
	fi	
}

check_redhat (){
	installer=$(check_redhat_installer)
	if [[ -z $($installer list installed $1 --quiet ) ]]; then
		return 1
	else 
		return 0
	fi
}

check_ubuntu(){
	if [[ $(apt list --installed $1 2>/dev/null ) != "Listing..." ]]; then
		return 1
	else
		return 0
	fi
}

check_suse(){
	if [[ -z $(zypper search --installed-only $1 | grep $1) ]]; then 
		return 0 
	else 
		return 1
	fi
}

if [[ ! -f /etc/os-release ]]; then echo "/etc/os-release is missing." && exit 1; fi
	
. /etc/os-release
if [[ -z "${ID}" ]]; then echo "ID is empty" && exit 2; fi





check_installed(){
case $ID in
	"centos"| "rocky" | "rhel")
		check_redhat $package
			if [[ $? -eq 0 ]]; then
			red_echo $not_inst
		else
			green_echo $inst
		fi	
		;;
	"ubuntu")
		apt-get update --quiet  > /dev/null 2>&1
		check_ubuntu $package # 
		if [[ $? -eq 0 ]]; then
			red_echo $not_inst
		else
			green_echo $inst
		fi	
		;;	
	"sles"|"opensuse-leap")
		check_suse $package
		if [[ $? -eq 0 ]]; then
			red_echo $not_inst
		else
			green_echo $inst
		fi	
		;;
	*) 
		red_echo "$ID distro is not supported"		
esac
}

package="${1}"
check_installed $package



