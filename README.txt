$ ansible -i hosts -m command -a 'chdir=/root/ansible ./runme.sh' all

thorbardin, vkvm1:	launch_256G.sh
palanthas:		launch_256G.sh
daltigoth:		launch_128G.sh


NUMA guests (must remove hugepages):
# virsh dumpxml overcloud-compute-5
[....]
  <cpu mode='host-passthrough' check='none'>
    <numa>
      <cell id='0' cpus='0-3' memory='8192000' unit='KiB'/>
      <cell id='1' cpus='4-7' memory='8192000' unit='KiB'/>
    </numa>
  </cpu>


$ ansible-playbook -i inventories/virt-env-ospd/hosts \
	playbooks/virt-env-ospd/ospd_13_palanthas.yml \
	--tags 'virt-env-ospd-undercloud,virt-env-ospd-site-specific' 


