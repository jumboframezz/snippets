#!/bin/bash +x

dstdir=/storage/local/kvm-disks
start="no"


if [[ ! -d $dstdir ]]; then 
	echo "destination directory $destdir does not exists."
	exit 1
fi 


for i in "$@"
do
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
    -s=*)
	start="yes"
	shift 	
    ;; 

    
    *)
        #  echo "$0 -s|--soruce=<vm name>  -d|--destination=<destination vm>"
    ;;
esac
done


case $vmtype in
	c8)
		vmsource=centos8-template
	;;
	c7)
		vmsource=centos7-template
	;;
        c7-small)
		vmsource=c7-small
	;;
	c72)	vmsource=centos7.2-template
	;;
	u18)
		vmsource=ubuntu18.04
	;; 
	u16)
		vmsource=ubuntu16-template
	;;
	u20)
		vmsource=ubuntu20-template 
	;;
	rhel)
		 vmsource=rhel8.4-template 
	;;
	rocky)
		vmsource=rocky8-template
	;;
	alma)
		vmsource=alma8-template
	;;
	debian)
		vmsource=debian-template
	;;
	suse)
		vmsource=suse-leap-template
	;;
	*)
		cat << EOF
c8
c7 
u18
u20
rhel
rocky
alma
debian
EOF
	exit 0
	;;

	
esac




echo "Type	 : " $vmtype
echo "Source     : " $vmsource
echo "Destination: " $vmdst
echo "Dst dir	 : " $dstdir

if [ -z "$vmdst" ]; then
	echo "Error: Use -d=<dest-machine> "
	exit 1 
fi


status=$( virsh domstate  $vmsource)

if [ "$status" == "running" ]; then
	echo "$vmsource is running, cannot continue"
	exit 1
else 
	echo "Domain status: $status" 
fi

echo virt-clone  --original $vmsource  --name $vmdst --file $dstdir/$vmdst $disk_line  #-mac RANDOM

virt-clone  --original $vmsource  --name $vmdst --file $dstdir/$vmdst $disk_line  #-mac RANDOM

virsh domblklist $vmdst

if [[ $start == "yes" ]]; then
	echo "Starting $vmdist"
	virsh start $vmdist
fi




