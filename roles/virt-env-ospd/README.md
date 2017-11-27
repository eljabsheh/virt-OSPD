Ansible role virt-env-ospd
=========

This role allows you to deploy an OSP-director virtual platform. Two methods are available in this role:

 - **CDN - stable** *(RHSM subscriptions needed)*
 - **rhos-release - testing** *(VPN access needed)*

Supported OSP-d versions:

 - **7-director** *(stable or puddle)*
 - **8-director** *(stable or puddle)*

Requirements
------------

Ansible 2.x and a Red Hat 7.x hypervisor with a RHSM subscription and few repositories for ``libvirt-daemon-kvm``, ``qemu-kvm``, etc...

```
#### If your distribution has an Ansible 2.x RPM ####
# yum install ansible -y
# ansible --version
```
Or:
```
# yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
# yum install python-pip libffi-devel openssl-devel gcc -y
# pip install --upgrade pip
# pip install ansible
# ansible --version
```

Then prepare the working directory.
```
# mkdir -p ~/ansible/{roles,inventories/virt-env-ospd,playbooks/virt-env-ospd/files/{ospd7,ospd8}} ; cd ~/ansible
# cat << EOF > inventories/virt-env-ospd/hosts
[hypervisor]
my-great-hypervisor-hostname ansible_host=10.10.10.10

[undercloud]
EOF
# cat << EOF > ansible.cfg
[defaults]
host_key_checking = False
roles_path = ./roles
EOF
# touch playbooks/virt-env-ospd/env1.yml
# cd ~/ansible
# export GIT_SSL_NO_VERIFY=false ; git clone https://gitlab.cee.redhat.com/RCIP/virt-env-ospd.git roles/virt-env-ospd
```

``env1.yml`` will be your playbook, so just copy the example in the [Example Playbook](#example-playbook) section below in the page and change some values to make it fit with your needs.

If you are running the playbook on the hypervisor it self, make sure that you have added the SSH ``root`` public key to the ``/root/.ssh/authorized_keys`` file. 

Red Hat VPN access is needed on the hypervisor if you choose to install a puddle or if you want to clone the ``rcip-tools`` Gitlab repository.

A ``cloud-init`` ISO is mandatory to provision the ``undercloud`` virtual machine. If you don't know how to generate a ``cloud-init``, please have a look at the end of this document.

When everything seems good to you, just run the playbook !
```
# ansible-playbook -i inventories/virt-env-ospd/hosts playbooks/virt-env-ospd/env1.yml
```

Make sure that you have enough space in ``/var/lib/libvirt/images`` for the virtual machines creation.

The playbook takes around 20 minutes to be completed.

Images
-----------

If you choose to upload the images *(pretty good idea)*, you will have to download them before and define the variable ``virt_env_ospd_upload_images`` to ``true`` in your playbook.

Depending if you are using ``rhos-release`` your images will be downloaded from different sources *(below, images are used with ``rhos-release``)*.

```
# cd ~/ansible/playbooks/virt-env-ospd/files/ospd8
# wget http://rhos-release.virt.bos.redhat.com/mburns/latest-8.0-images/ironic-python-agent.tar
# wget http://rhos-release.virt.bos.redhat.com/mburns/latest-8.0-images/overcloud-full.tar
# cd ../ospd7
# wget http://rhos-release.virt.bos.redhat.com/mburns/latest-7.0-images/deploy-ramdisk-ironic.tar
# wget http://rhos-release.virt.bos.redhat.com/mburns/latest-7.0-images/discovery-ramdisk.tar
# wget http://rhos-release.virt.bos.redhat.com/mburns/latest-7.0-images/overcloud-full.tar
```

When ``virt_env_ospd_upload_images`` is not define, the ``overcloud`` images will be automatically downloaded on the ``undercloud`` during the playbook execution.

The ``rhel-guest-image-7.xxxxxxx.qcow2`` image will be downloaded if the file doesn't exists in ``/var/lib/libvirt/images``.

Role Variables
--------------

```
virt_env_ospd_hypervisor: true
virt_env_ospd_tuned: true
virt_env_ospd_rcip_tools: true
virt_env_ospd_rhn_unsubscribe: true
virt_env_ospd_rhos_release: true
virt_env_ospd_disable_repos: true
virt_env_ospd_ironic_introspection: true
virt_env_ospd_director_version: 8-director
virt_env_ospd_vm_name: baremetal
virt_env_ospd_undercloud_hostname: manager.mydomain.lab
virt_env_ospd_neutron_dns: 8.8.8.8
virt_env_ospd_bridges:
  - director-pxe
  - director-full

# IMAGES
virt_env_ospd_upload_images: false
virt_env_ospd_images_link:
  - http://rhos-release.virt.bos.redhat.com/mburns/latest-7.0-images/deploy-ramdisk-ironic.tar
  - http://rhos-release.virt.bos.redhat.com/mburns/latest-7.0-images/discovery-ramdisk.tar
  - http://rhos-release.virt.bos.redhat.com/mburns/latest-7.0-images/overcloud-full.tar

# INSTACKENV.JSON
instackenv_pm_type: pxe_ssh
instackenv_pm_addr: 192.168.122.1
instackenv_pm_user: root
instackenv_pm_password: "{{ virt_env_ospd_ssh_prv }}"
instackenv_cpu: 4
instackenv_memory: 8192
instackenv_disk: 80
instackenv_arch: x86_64

# UNDERCLOUD VM
virt_env_ospd_undercloud:
  name: undercloud
  disk_size: 40g
  cpu: 8
  mem: 16384
  cloud_init_iso: cloud-init.iso

# CEPH VM
virt_env_ospd_ceph:
  name: ceph
  disk_size: 40g
  cpu: 4
  mem: 4096
  mac: 52:54:00:aa:d3:8
  vm_count: 3
  extra_disk_count: 3

# CEPH EXTRA DISKS
virt_env_ospd_ceph_extra_disk:
  - { name: sdb, size: 10g, format: qcow2, bus: sata }
  - { name: sdc, size: 10g, format: qcow2, bus: sata }
  - { name: sdd, size: 10g, format: qcow2, bus: sata }

# SWIFT VM
virt_env_ospd_swift:
  name: swift
  disk_size: 40g
  cpu: 4
  mem: 4096
  mac: 52:54:00:aa:d3:5
  vm_count: 3
  extra_disk_count: 3

# SWIFT EXTRA DISKS
virt_env_ospd_swift_extra_disk:
  - { name: sdb, size: 10g, format: qcow2, bus: sata }
  - { name: sdc, size: 10g, format: qcow2, bus: sata }
  - { name: sdd, size: 10g, format: qcow2, bus: sata }

# CONTROL VM
virt_env_ospd_control:
  name: control
  disk_size: 40g
  cpu: 4
  mem: 8192
  mac: 52:54:00:aa:d3:6
  vm_count: 3

# COMPUTE VM
virt_env_ospd_compute:
  name: compute
  disk_size: 40g
  cpu: 4
  mem: 4096
  mac: 52:54:00:aa:d3:7
  vm_count: 3

virt_env_ospd_block:

# LIBVIRT
# To get machine types available execute this command:
# /usr/libexec/qemu-kvm -machine help
virt_env_ospd_machine_type: pc-i440fx-rhel7.0.0
virt_env_ospd_libvirt_bridge: virbr0
virt_env_ospd_libvirt_net_name: default
virt_env_ospd_disk_os_bus: sata

# Because virtio driver doesn't work well with Ironic
# depending of the qemu-kvm version (rhev or not)
# Change it if needed :)
virt_env_ospd_net_driver_pxe: e1000

# Some issues during overcloud deployment due to virtio
# network driver (resource create failed)
# Change it if needed :)
virt_env_ospd_net_driver: e1000

virt_env_ospd_cache_mode: none
```

Variables in ``vars`` directory.

```
# file: roles/virt-env-ospd/vars/7-director.yml
virt_env_ospd_undercloud_packages:
  - vim
  - strace
  - tcpdump
  - screen
  - git
  - python-rdomanager-oscplugin
  - libguestfs-tools
  - sysstat
  - sos
  - bash-completion

# file: roles/virt-env-ospd/vars/8-director.yml
virt_env_ospd_undercloud_packages:
  - vim
  - strace
  - tcpdump
  - screen
  - git
  - python-tripleoclient
  - libguestfs-tools
  - sysstat
  - sos
  - bash-completion

# file: roles/virt-env-ospd/vars/main.yml
virt_env_ospd_dir: /var/lib/libvirt
virt_env_ospd_format: qcow2

# HYPERVISOR PACKAGES
virt_env_ospd_packages:
  - bridge-utils
  - qemu-img
  - qemu-kvm
  - genisoimage
  - tuned
  - libvirt-daemon-kvm

# RHEL GUEST IMAGE
virt_env_ospd_guest_name: rhel-guest-image-7.2-20160302.0.x86_64.qcow2 
virt_env_ospd_guest_link: http://download.eng.bos.redhat.com/brewroot/packages/rhel-guest-image/7.2/20160302.0/images/{{ virt_env_ospd_guest_name }}
```

Example Playbook
----------------

```
---
# HYPERVISOR #
- hosts: hypervisor
  remote_user: root

  roles:
    - virt-env-ospd

  vars:
    # NETWORK #
    virt_env_ospd_bridges:
      - gtrellu-pxe
      - gtrellu-full

    # VM #
    virt_env_ospd_vm_name: gtrellu

    # UNDERCLOUD NODE #
    virt_env_ospd_undercloud:
      name: gtrellu_ospd8
      disk_size: 40g
      cpu: 8
      mem: 16384
      cloud_init_iso: cloud-init-gtrellu.iso

      # CEPH VM
    virt_env_ospd_ceph:
      name: ceph
      disk_size: 40g
      cpu: 4
      mem: 4096
      # The last digit is not missing !!
      mac: 52:54:00:aa:e3:8
      vm_count: 3
      extra_disk_count: 3
    
    # CEPH EXTRA DISKS
    virt_env_ospd_ceph_extra_disk:
      - { name: sdb, size: 10g, format: qcow2, bus: sata }
      - { name: sdc, size: 10g, format: qcow2, bus: sata }
      - { name: sdd, size: 10g, format: qcow2, bus: sata }
    
    # SWIFT VM
    virt_env_ospd_swift:
      name: swift
      disk_size: 40g
      cpu: 4
      mem: 4096
      # The last digit is not missing !!
      mac: 52:54:00:aa:e3:5
      vm_count: 3
      extra_disk_count: 3
    
    # SWIFT EXTRA DISKS
    virt_env_ospd_swift_extra_disk:
      - { name: sdb, size: 10g, format: qcow2, bus: sata }
      - { name: sdc, size: 10g, format: qcow2, bus: sata }
      - { name: sdd, size: 10g, format: qcow2, bus: sata }

    # CONTROL VM
    virt_env_ospd_control:
      name: control
      disk_size: 40g
      cpu: 4
      mem: 8192
      # The last digit is not missing !!
      mac: 52:54:00:aa:e3:6
      vm_count: 3
    
    # COMPUTE VM
    virt_env_ospd_compute:
      name: compute
      disk_size: 40g
      cpu: 4
      mem: 4096
      # The last digit is not missing !!
      mac: 52:54:00:aa:e3:7
      vm_count: 3

# UNDERCLOUD #
- hosts: undercloud
  remote_user: root

  roles:
    - virt-env-ospd

  vars:
    # UNDERCLOUD NODE #
    virt_env_ospd_undercloud_hostname: ospd8.gtrellu.lab
    virt_env_ospd_director_version: 8-director
    virt_env_ospd_upload_images: false

    virt_env_ospd_undercloud_conf:
      - { section: 'DEFAULT', option: 'enable_tempest', value: 'true' }
      - { section: 'DEFAULT', option: 'inspection_extras', value: 'true' }

    # BAREMETAL NODES #
    # You can use this command to get the SSH key on one line:
    # sed ':a;N;$!ba;s/\n/\\n/g' ~/.ssh/id_rsa
    virt_env_ospd_ssh_prv: -----BEGIN RSA PRIVATE KEY-----\nPrivate key from the hypervisor\n-----END RSA PRIVATE KEY-----

    # The line number should be equal to the number
    # of virtual machines
    undercloud_nodes:
      - { mac: "52:54:00:aa:e3:61", profile: "control" }
      - { mac: "52:54:00:aa:e3:62", profile: "control" }
      - { mac: "52:54:00:aa:e3:63", profile: "control" }
      - { mac: "52:54:00:aa:e3:81", profile: "storage" }
      - { mac: "52:54:00:aa:e3:82", profile: "storage" }
      - { mac: "52:54:00:aa:e3:83", profile: "storage" }
      - { mac: "52:54:00:aa:e3:71", profile: "compute" }
      - { mac: "52:54:00:aa:e3:72", profile: "compute" }
      - { mac: "52:54:00:aa:e3:73", profile: "compute" }
      - { mac: "52:54:00:aa:e3:51", profile: "swift" }
      - { mac: "52:54:00:aa:e3:52", profile: "swift" }
      - { mac: "52:54:00:aa:e3:53", profile: "swift" }

    virt_env_ospd_flavors:
      - { name: "control", ram: "4096", disk: "20", cpu: "2" }
      - { name: "compute", ram: "4096", disk: "20", cpu: "2" }
      - { name: "storage", ram: "4096", disk: "20", cpu: "2" }
      - { name: "swift", ram: "4096", disk: "20", cpu: "2" }
```

How to generate a cloud-init
-------------

The ``cloud-init-gtrellu.iso`` will be generated in ``/root/ansible/playbooks/virt-env-ospd/files/`` directory.

```
# mkdir ~/cloud-init ; cd ~/cloud-init
# cat << EOF > meta-data
instance-id: 2016031801
local-hostname: ospd8.gtrellu.lab
EOF

# cat << EOF > user-data
#cloud-config
users:
  - default
  - name: stack
    gecos: RedHat Openstack User
    ssh-authorized-keys:
      - ADD---YOUR---SSH---PUBLIC---KEY
    sudo:
      - ALL=(root) NOPASSWD:ALL
  - name: root
    ssh-authorized-keys:
      - ADD---YOUR---SSH---PUBLIC---KEY

write_files:
  - path: /etc/sysconfig/network-scripts/ifcfg-eth0
    content: |
      DEVICE=eth0
      TYPE=Ethernet
      BOOTPROTO=dhcp
      ONBOOT=yes
  - path: /etc/sysconfig/network-scripts/ifcfg-eth2
    content: |
      DEVICE=eth2
      TYPE=Ethernet
      BOOTPROTO=none
      ONBOOT=yes
  - path: /etc/sysconfig/network-scripts/ifcfg-eth2.10
    content: |
      DEVICE=eth2.10
      TYPE=vlan
      BOOTPROTO=none
      ONBOOT=yes
      IPADDR=10.0.0.1
      NETMASK=255.255.255.0
  - path: /etc/sysctl.conf
    content: |
      net.ipv4.ip_forward = 1

runcmd:
  - /usr/bin/systemctl restart network
  - /usr/sbin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
  - /usr/sbin/service iptables save
EOF

# genisoimage -output /root/ansible/playbooks/virt-env-ospd/files/cloud-init-gtrellu.iso -volid cidata -joliet -rock user-data meta-data
```

Register to RHSM
---------
If you don't want to use ``rho-release``, you will have to register the server to the RHSM. As usual to perform this action you will need your Red Hat credentials and declare them to the playbook and then enable repositories.

**With RHSM subscription, you will not be able to deploy puddle versions.**

```
virt_env_ospd_rhos_release: false
rhn_username: gtrellu@redhat.com
rhn_password: xxxxxxxxxx
rhn_pool_id: 8a85f98144844aff014488d058bf15be
rhn_repos:
  - rhel-7-server-rpms
  - rhel-7-server-extras-rpms
  - rhel-7-server-rh-common-rpms
  - rhel-ha-for-rhel-7-server-rpms
  - rhel-7-server-openstack-7.0-rpms
  - rhel-7-server-openstack-7.0-director-rpms
  - rhel-7-server-rhceph-1.3-osd-rpms
  - rhel-7-server-rhceph-1.3-mon-rpms
  - rhel-7-server-rhceph-1.3-tools-rpms
```

If you plan to use OSP-d 8 via the CDN, you will have to replace these repositories:

* ``rhel-7-server-openstack-7.0-rpms``
* ``rhel-7-server-openstack-7.0-director-rpms``

By these ones:

* ``rhel-7-server-openstack-8-rpms``
* ``rhel-7-server-openstack-8-director-rpms``

Known issues
-------

OS disk with VirtIO driver and extra disks with SATA driver can trouble the introspection process and make the overcloud deployment failed due to "**No valid host found**" error. Extra disks attached to virtual machine are used as system disk because ``/dev/sdX`` is before ``/dev/vdX``. To fix, make sure that your are not using the same bus driver for all disks.

VirtIO driver for PXE interface make the introspection fail depending of the driver version (``qemu-kvm`` vs ``qemu-kvm-rhev``). To "fix", make sure your PXE interface use ``e1000`` driver instead of VirtIO.

```
WARNING ironic_inspector.plugins.standard [-] The following interfaces were invalid or not eligible in introspection data for node with BMC  and were excluded: {u'ens5': {u'ip': None, u'mac': u'52:54:00:75:36:fd'}, u'ens6': {u'ip': None, u'mac': u'52:54:00:b9:0a:a3'}, u'ens3': {u'ip': u'192.0.2.100', u'mac': u'52:54:00:aa:e3:61'}}
ERROR: ironic_inspector.utils [-] Could not find a node for attributes {'bmc_address': u'', 'mac': [u'52:54:00:3b:f1:b2']}
```

In some case, we had the opposite situation, ``e1000`` returned this issue and VirtIO solved the problem.... Just tweak the ``virt_env_ospd_net_driver_pxe`` via the playbook if needed.

VirtIO driver for other interfaces make the deployment fail during the Neutron ports creation *(TenantPort)*.  Should be retest with the last 8 puddle version.

The first time than you run the playbook, this one can fail due to a ``tuned`` error related to DBUS.
```
DBus call to Tuned daemon failed
Trying to (re)start tuned...
```
Just rerun the playbook.

Limitation
-------

Only 9 virtual machines max per profile can be created *(9 controller, 9 Ceph, 9 compute, 9 Swift)*.

It means that your virtual platform will never be larger than 36 nodes *(virtual machines)*.

Removing and restart
--------

If you want to re-run the playbook to deploy a new virtual environment, follow the next actions:
```
# for i in $(virsh list --all | awk '$2 ~ /gtrellu/ { print $2 }'); do virsh destroy $i; done
# for i in $(virsh list --all | awk '$2 ~ /gtrellu/ { print $2 }'); do virsh undefine $i; done
# rm -f /var/lib/libvirt/images/gtrellu*
# cd ~/ansible
# ansible-playbook -i inventories/virt-env-ospd/hosts playbooks/virt-env-ospd/env1.yml
```
It's very important to delete the QCOW2 files related to the virtual machines !

License
-------

Apache

Author Information
------------------

2016 - Gaëtan Trellu
