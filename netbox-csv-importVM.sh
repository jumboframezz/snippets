#!/bin/bash
# shellcheck disable=1091
# Modified on 27-Jun-2023 lachezarg@nsogroup.com


declare -A colors=(['red']='\e[31m' ['green']='\e[32m' ['yellow']='\e[33m' ['blue']='\e[34m' ['magenta']='\e[35m' ['cyan']='\e[36m' \
                [light_red]='\e[91m' ['light_green']='\e[92m' [light_yellow]='\e[93m' [light_blue]='\e[94m'\
                [bold]='\e[1m' ['no_color']='\033[0m' [bold_green]='\e[1;\e[32m' [bold_white]='\e[1;\e[97m'  )

_echo() {
       echo -e "${colors[$2]}${1}${colors[no_color]}"
}

err_exit(){
	_echo "$1" red
	exit "$2"
}

get_cluster(){

[ -z "$1" ] && err_exit "Provide an ip as 1st argument" 130
ip_address="$1"
case "$ip_address" in
    10.10*)
        nb_cluster="BGHQ-BK-VCI01" 
		cf_Hypervisor="https://bghq-bk-vci01.office.corp" ;;
    10.27*)
        nb_cluster="BGDC-BK-VCI1" 
		cf_Hypervisor="https://bgdc-bk-vci1.office.corp/" ;;
	10.28*)
        nb_cluster="BGDC-BK-VCI1" 
		cf_Hypervisor="https://bgdc-bk-vci1.office.corp/" ;;
	10.40*)
        nb_cluster="DEDC-BK-VCI01" 
		cf_Hypervisor="https://dedc-bk-vci1.office.corp" ;;
	10.41*)
        nb_cluster="DEDC-BK-VCD01" 
		cf_Hypervisor="	https://dedc-bk-vcd1.office.corp" ;;
    *)
		err_exit  "Plase modify script and provide entry for ip address $ip_address" 160 ;;
esac
}

nb_hostname=$( hostname )
nb_status="active"
nb_role="Server"
nb_tentant="Linux Team"

if [[ -f "/etc/os-release" ]]; then
        .  /etc/os-release
else
        err_exit "Cannot find os-release" 131
fi

nb_cpus=$( grep -c "processor" /proc/cpuinfo )
nb_memory=$(free -tm | grep Mem: | awk '{print $2}')
nb_disk=$(df -h / |  awk '{print $2}' | grep -o "[0-9][0-9]")

nb_comments="Machine imported from .csv"
cf_Accessfrom=""

case "${ID}" in
	"rocky")
		cf_FQDN=$(hostname -f)
		nb_platform="RedHat"
		yum -y install jq
		;;
	"centos")
		cf_FQDN=$(hostname -f)
		nb_platform="RedHat"
		yum -y install jq
		;;
	"ubuntu")
		cf_FQDN=$(hostname)
		apt -y install jq
		nb_platform=${ID^}
		;;
	*)
		cf_FQDN=$(hostname)
		;;
esac

cf_Application=""
cf_Environment=""

cf_LastupdatedL=""
cf_Product=""
cf_ServiceURL=""
cf_SNOWid=""
cf_SNOWRole=""
if [[ -f "/etc/redhat-release" ]]; then 
        cf_OSversion=$(cat /etc/redhat-release)
else
        cf_OSversion="${VERSION}"
fi


if [[ -z "$1" ]]; then 
    # Get interface for default route
	nb_interface=$(ip --json  r l  | jq -r '.[] | select(.dst == "default").dev')
else
	nb_interface=$1
fi
[ -z "$nb_interface" ] && err_exit "Cannot determine network interface name"
if  [[ -f "/usr/sbin/ip" || -f "/sbin/ip" ]]; then
	_echo "Using ip command" green
	nb_mac=$(ip  -4 --json --pretty  link list  dev  "$nb_interface" | jq -r  ".[].address")
	nb_ip=$(ip -4 --json --pretty address list dev "$nb_interface"  | jq -r  ".[].addr_info[].local")
	nb_prefixlen=$(ip -4 --json --pretty address list dev "$nb_interface"  | jq -r  ".[].addr_info[].prefixlen")
	nb_ipaddress="$nb_ip/$nb_prefixlen"

else	
	_echo "using ifconfig" yellow
	nb_mac=$(ifconfig "$nb_interface" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
	nb_ipaddress=$(ip -o -4 addr list "$nb_interface" | awk '{print $4}')

fi
# nb_cluster=$(get_cluster "$nb_ipaddress")
get_cluster "$nb_ipaddress"
[ -z "$nb_cluster" ] && err_exit "nb_cluster is empty" 133
[ -z "$cf_Hypervisor" ] && err_exit "cf_Hypervisor is empty" 134
_echo "\n------- VM DATA -------\n" blue

echo "name,status,role,cluster,tenant,platform,vcpus,memory,disk,comments,cf_Access from:,cf_FQDN,cf_Application,cf_Environment,cf_Hypervisor,cf_Last updatedL,cf_Product,cf_Service URL,cf_SNOW id,cf_SNOW Role,cf_OS version"
echo "$nb_hostname,$nb_status,$nb_role,$nb_cluster,$nb_tentant,$nb_platform,$nb_cpus,$nb_memory,$nb_disk,$nb_comments,$cf_Accessfrom,$cf_FQDN,$cf_Application,$cf_Environment,$cf_Hypervisor,$cf_LastupdatedL,$cf_Product,$cf_ServiceURL,$cf_SNOWid,$cf_SNOWRole,$cf_OSversion"
_echo "\n------- INTERFACE -------\n" blue 

echo "virtual_machine,name,enabled,mac_address,mtu"
echo "$nb_hostname,$nb_interface,true,$nb_mac,1500"

_echo "\n------- IP ADDRESS -------\n" blue 

echo "address,status,virtual_machine,interface,is_primary"
echo "$nb_ipaddress,active,$nb_hostname,$nb_interface,true"

_echo "\n------- END -------\n" blue
#set -x
# data=$(curl -I -X GET "https://netbox.office.corp/api/ipam/ip-addresses/?address=${nb_ipaddress}"  \
#         -H "Accept: application/json; indent=4" \
#         -H  "Authorization: Token a4d46e950bbfc04abb3e1d81b54b39c2447f0eac" \
#         -H  "X-CSRFToken: mRd1E7VN4TxHnicmFQCcLd3AYeZqDkkDUyww2su45LRIkG1EZf9PUwk9gZXJrroV" )
# echo $data
# is_found=$(echo $data | jq ".count")
# echo "${is_found} found for $nb_ipaddress"
# if [[ -f "/usr/sbin/ifconfig" ]]; then 
# 	ifconfig  
# else
# 	ip a l 
# fi
