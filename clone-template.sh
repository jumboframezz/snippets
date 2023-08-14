#!/bin/bash +x
# shellcheck disable=2086
export LANGUAGE=en_US
declare -A colors=(['red']='\e[31m' ['green']='\e[32m' ['yellow']='\e[33m' ['blue']='\e[34m' ['magenta']='\e[35m' ['cyan']='\e[36m' \
                [bold]='\e[1m' ['no_color']='\033[0m')

dstdir=/storage/local/kvm-disks
start="no"

_echo() {
       echo -e "${colors[$2]}${1}${colors[no_color]}"
}


if [[ ! -d $dstdir ]]; then 
        _echo "Destination directory $dstdir does not exists.\n" red
        exit 130
fi 

for i in "$@"; do
        case $i in
                -s=*|--source=*)
                        template="${i#*=}"
                        shift # past argument=value
                ;;

                -d=*|--destination=*)
                        vmdst="${i#*=}"
                        shift # past argument=value
                ;;

                -t=*|--type=*)
                        vmtype="${i#*=}"
                        shift # past argument=value
                ;;
                -start=*)
                start="yes"
                shift 
                ;; 
        esac
done

declare -A vm_types=( \
                [c8]='centos8-template' [c7]='centos7-template' [c7-small]='c7-small' [c72]='centos7.2-template'\
                [u16]='ubuntu18.04' [u20]='ubuntu20-template' [u22]='ubuntu22-template' \
                [rhel]='rhel8.4-template' [rocky]='rocky8-template' [rocky_small]='rocky8_small-template' [rocky9]='rocky9-template' \
                [debian]='debian-template' \
		[debian12]='debian12-template' \
                [suse]='suse-leap-15.4-template' \
                [freebsd]='FreeBSD-template' \
                [alma8]='alma8-template' )

vmsource="${vm_types[$vmtype]}"

header=$(printf "\n%-16s %-21s\n"  "Key" "Template")
_echo "$header" bold
for i in "${!vm_types[@]}"; do
        printf "%-15s  %-20s\n" $i ${vm_types[$i]}
done

_echo "Type         : $vmtype" yellow
_echo "Source       : $vmsource" yellow
_echo "Destination  : $vmdst" yellow
_echo "Dst dir      : $dstdir" yellow

if [ -z "$vmdst" ]; then
        echo "Error: Use -d=<dest-machine> "
        exit 1 
fi

status=$( virsh domstate  "$vmsource"  2>/dev/null )
[ $? -ne 0 ] && _echo "No such domain $vmsource" red && exit 130

if [ "$status" == "running" ]; then
        _echo "$vmsource is running, cannot continue" red
        exit 1
else 
        _echo "Domain status: $status"  green
fi

_echo "virt-clone  --original $vmsource  --name $vmdst --file $dstdir/$vmdst.qcow2 $disk_line  #-mac RANDOM" yellow
virt-clone  --original $vmsource  --name $vmdst --file $dstdir/$vmdst.qcow2   #-mac RANDOM
echo -e "${colors["green"]}"
virsh domblklist $vmdst
echo -e "${colors["no_color"]}"

if [[ $start == "yes" ]]; then
        _echo "Starting $vmdst"  gren
        virsh start "$vmdst"
else
        _echo "You may add -s=yes to start $vmdst automatically" bold
fi