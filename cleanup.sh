#!/bin/bash
for vm in $(sudo virsh list |awk '{ if ( $1 ~ /[0-9]/ ) { print $2 } }')
do
	sudo virsh destroy $vm
done

for vm in $(sudo virsh list --all |awk '{ if ( $1 == "-" ) { print $2 } }')
do
	sudo virsh undefine $vm
	sudo /bin/rm -rfv /var/lib/libvirt/images/${vm}*.qcow2
done
