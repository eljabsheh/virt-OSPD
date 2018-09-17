#!/bin/bash

# Give hints:
echo -e "(II) Here are some suggestions for some specific systems:"
echo -e "----------------------------------------------"
echo -e " - p50r or ravenvale\t: 32G config"
echo -e " - daltigoth\t\t: 64G config"
echo -e " - palanthas\t\t: 160G config"
echo -e " - thorbardin\t\t: 192G config"
echo -e " - vkvm1\t\t: 256G config"
echo -e "----------------------------------------------\n"

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
select option in 32G 64G 128G 160G 192G 256G
do
	case ${option} in
		32G|64G|128G|160G|192G|256G)
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
