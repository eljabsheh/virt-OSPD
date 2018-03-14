#!/bin/bash
# host: thorbardin
set -x
ansible-playbook -i inventories/virt-env-ospd/hosts playbooks/virt-env-ospd/ospd_256G.yml

# ansible-playbook -i inventories/virt-env-ospd/hosts playbooks/virt-env-ospd/ospd.yml --tags virt-env-ospd-virtualbmc
# ansible-playbook -i inventories/virt-env-ospd/hosts playbooks/virt-env-ospd/ospd.yml --tags virt-env-ospd-prepare
# ansible-playbook -i inventories/virt-env-ospd/hosts playbooks/virt-env-ospd/ospd.yml --tags virt-env-ospd-hypervisor,virt-env-ospd-undercloud,virt-env-ospd-templates

