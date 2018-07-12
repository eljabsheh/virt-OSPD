#!/bin/bash
# Root check
if [ $UID -ne 0 ]; then
        echo "Run $0 as root!" ; exit 127
fi

for vm in $(virsh list|grep -vw instack |awk '{ if ( $1 ~ /[0-9]/ ) { print $2 } }')
do
	case $vm in 
		overcloud*)
			virsh destroy $vm
			;;
		*)
	esac
done

for vm in $(virsh list --all|grep -vw instack |awk '{ if ( $1 == "-" ) { print $2 } }')
do
	case $vm in 
		overcloud*)
			virsh undefine $vm
			if [ -x /usr/bin/vbmc ]; then
				vbmc delete $vm
			fi
			/bin/rm -fv /var/lib/libvirt/images/${vm}*.qcow2 /shared/kvm0/images/${vm}*.qcow2
			;;
		*)
	esac
done
