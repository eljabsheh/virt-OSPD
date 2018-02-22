#!/bin/bash
# Root check
if [ $UID -ne 0 ]; then
        echo "Run $0 as root!" ; exit 127
fi

for vm in $(virsh list |awk '{ if ( $1 ~ /[0-9]/ ) { print $2 } }')
do
	virsh destroy $vm
done

for vm in $(virsh list --all |awk '{ if ( $1 == "-" ) { print $2 } }')
do
	virsh undefine $vm
	/bin/rm -fv /var/lib/libvirt/images/${vm}*.qcow2
done
