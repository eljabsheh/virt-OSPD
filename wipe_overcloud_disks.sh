#!/bin/bash
# Root check
STIMEOUT=30
[ "root" != "$USER" ] && exec sudo $0 "$@"

if [ $UID -ne 0 ]; then
        echo "Run $0 as root!" ; exit 127
fi

for vm in $(virsh list|grep -vw instack |awk '{ if ( $1 ~ /[0-9]/ ) { print $2 } }')
do
	case $vm in 
		overcloud-*)
			virsh destroy $vm
			;;
		*)
	esac
done

for vm in $(virsh list --all|grep -vw instack |awk '{ if ( $1 == "-" ) { print $2 } }')
do
	case $vm in 
		overcloud-*)
			# Start by looking at disks listed in the domain config
			for mydisk in $(virsh domblklist ${vm}| \
				egrep  '[[:space:]]/.*boot')
			do
				/bin/rm -fv ${mydisk}
			done
			# Just to be sure, make an extra clean pass
			for mydir in $(virsh domblklist ${vm}| \
				egrep  '[[:space:]]/.*boot'| \
				sed -e  's@^.*[[:space:]]/@\/@'| \
				xargs -n1 dirname| \
				sort -u)
			do
				qemu-img create -f qcow2 ${mydir}/${vm}-boot.qcow2 128G
			done
			;;
		*)
	esac
done
