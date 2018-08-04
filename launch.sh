#!/bin/bash

# Select OSP version..
PS3="(II) Please select an OSP version: "
select option in 8 9 10 11 12 13
do
	case ${option} in
		8|9|10|11|12|13)
			OSP=${option}
			break
			;;
		*)
			echo "(**) Wrong option select, try again..."
			;;
	esac
done

# Select RAM
PS3="(II) Please select memory config for your hypervisor: "
select option in 32G 64G 128G 192G 256G
do
	case ${option} in
		32G|64G|128G|192G|256G)
			RAM=${option}
			break
			;;
		*)
			echo "(**) Wrong option select, try again..."
			;;
	esac
done

#
echo "(II) RH-OSP v${OSP} on ${RAM} RAM selected, proceeding..."
PLAYB="playbooks/virt-env-ospd/ospd_${OSP}_${RAM}.yml"
if [ -f ${PLAYB} ]; then
	set -x
	ansible-playbook -i inventories/virt-env-ospd/hosts ${PLAYB}
else
	echo "(**) No ansible playbook found at: ${PLAYB}"
fi
