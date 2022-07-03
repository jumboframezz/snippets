#!/bin/bash



nb_hostname=$(hostname -s)
nb_status="active"
nb_role="Server"
nb_cluster="BGDC-WH-XENI01"
nb_tentant="Linux Team"
if [[ -f "/etc/os-release" ]]; then
        .  /etc/os-release
else
        echo "Cannot find os-release"
fi

nb_platform="RedHat"
#if [[ "${ID}" -eq "Ubuntu" ]]; then
#        nb_platform="${ID}"
#fi

nb_cpus=$(cat /proc/cpuinfo  | grep processor | wc -l)
nb_memory=$(free -tm | grep Mem: | awk '{print $2}')
nb_disk=$(df -h / |  awk '{print $2}' | grep -o "[0-9][0-9]")

nb_comments=""
cf_Accessfrom=""

if [[ "${ID}" -eq "centos" ]]; then 
        cf_FQDN=$(hostname -f)
else
        cf_FQDN=$(hostname)
fi

cf_Application=""
cf_Environment=""
cf_Hypervisor=""
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

echo -e  "\n-------\n"

echo "name,status,role,cluster,tenant,platform,vcpus,memory,disk,comments,cf_Access from:,cf_FQDN,cf_Application,cf_Environment,cf_Hypervisor,cf_Last updatedL,cf_Product,cf_Service URL,cf_SNOW id,cf_SNOW Role,cf_OS version"
echo "$nb_hostname,$nb_status,$nb_role,$nb_cluster,$nb_tentant,$nb_platform,$nb_cpus,$nb_memory,$nb_disk,$nb_commentsi,$cf_Accessfrom,$cf_FQDN,$cf_Application,$cf_Environment,$cf_Hypervisor,$cf_LastupdatedL,$cf_Product,$cf_ServiceURL,$cf_SNOWid,$cf_SNOWRole,$cf_OSversion
"
echo -e "\n-------\n"

nb_mac=$(ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
nb_interface="eth0"
echo "virtual_machine,name,enabled,mac_address,mtu"
echo "$nb_hostname,$nb_interface,true,$nb_mac,1500"

echo -e  "\n-------\n"

nb_ipaddress=$(ip -o -4 addr list eth0 | awk '{print $4}')
echo "address,virtual_machine,interface,is_primary"
echo "$nb_ipaddress,$nb_hostname,eth0,true"


echo -e  "\n-------\n"


ifconfig eth0  | grep "inet \| ether"
