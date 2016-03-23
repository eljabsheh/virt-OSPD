Ansible role virt-env-ospd
=========

This role allows you to deploy an OSP-director virtual platform. Two methods are available in this role:

 - **CDN - stable** *(RHN subscriptions needed)*
 - **rhos-release - testing** *(VPN access needed)*

Supported OSP-d versions:

 - **7-director** *(stable or puddle)*
 - **8-director** *(puddle only at this time)*

Requirements
------------

Ansible 2.x and a Red Hat 7.x hypervisor with a RHN subscription and few repositories.

```
# yum install ansible -y
# ansible --version
```
Or:
```
# yum install python-pip
# pip install --upgrade pip
# pip install ansible
# ansible --version
```

Red Hat VPN access is needed on the hypervisor if you choose to install a puddle or if you want to clone the ``rcip-tools`` Gitlab repository.

A ``cloud-init`` ISO is mandatory to provision the ``undercloud`` virtual machine. If you don't know how to generate a ``cloud-init``, please have a look at the end of this document.

Role Variables
--------------

```
virt_env_ospd_hypervisor: true
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
virt_env_ospd_download_images: false
virt_env_ospd_upload_images: false
virt_env_ospd_images_link:
  - http://rhos-release.virt.bos.redhat.com/mburns/7.3-GA/images/deploy-ramdisk-ironic.tar
  - http://rhos-release.virt.bos.redhat.com/mburns/7.3-GA/images/discovery-ramdisk.tar
  - http://rhos-release.virt.bos.redhat.com/mburns/7.3-GA/images/overcloud-full.tar

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
  - { name: vdb, size: 10g, format: qcow2, bus: virtio }
  - { name: vdc, size: 10g, format: qcow2, bus: virtio }
  - { name: vdd, size: 10g, format: qcow2, bus: virtio }

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
  - { name: vdb, size: 10g, format: qcow2, bus: virtio }
  - { name: vdc, size: 10g, format: qcow2, bus: virtio }
  - { name: vdd, size: 10g, format: qcow2, bus: virtio }

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

# LIBVIRT
# To get machine types available execute this command:
# /usr/libexec/qemu-kvm -machine help
virt_env_ospd_machine_type: pc-i440fx-rhel7.0.0
virt_env_ospd_libvirt_bridge: virbr0
virt_env_ospd_libvirt_net_name: default
virt_env_ospd_disk_os_bus: virtio
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

# file: roles/virt-env-ospd/vars/8-director.yml
virt_env_ospd_undercloud_packages:
  - vim
  - strace
  - tcpdump
  - screen
  - git
  - python-tripleoclient
  - libguestfs-tools

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

# RHEL GUEST IMAGE
virt_env_ospd_guest_name: rhel-guest-image-7.2-20160302.0.x86_64.qcow2 
virt_env_ospd_guest_link: http://download.eng.bos.redhat.com/brewroot/packages/rhel-guest-image/7.2/20160302.0/images/{{ virt_env_ospd_guest_name }}

# Because virtio driver doesn't work well with Ironic
# depending of the qemu-kvm version (rhev or not)
virt_env_ospd_net_driver_pxe: e1000

# Some issues during overcloud deployment due to virtio
# network driver (resource create failed)
virt_env_ospd_net_driver: e1000

virt_env_ospd_cache_mode: none
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

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
      mac: 52:54:00:aa:e3:8
      vm_count: 3
      extra_disk_count: 3
    
    # CEPH EXTRA DISKS
    virt_env_ospd_ceph_extra_disk:
      - { name: vdb, size: 10g, format: qcow2, bus: virtio }
      - { name: vdc, size: 10g, format: qcow2, bus: virtio }
      - { name: vdd, size: 10g, format: qcow2, bus: virtio }
    
    # SWIFT VM
    virt_env_ospd_swift:
      name: swift
      disk_size: 40g
      cpu: 4
      mem: 4096
      mac: 52:54:00:aa:e3:5
      vm_count: 3
      extra_disk_count: 3
    
    # SWIFT EXTRA DISKS
    virt_env_ospd_swift_extra_disk:
      - { name: vdb, size: 10g, format: qcow2, bus: virtio }
      - { name: vdc, size: 10g, format: qcow2, bus: virtio }
      - { name: vdd, size: 10g, format: qcow2, bus: virtio }

    # CONTROL VM
    virt_env_ospd_control:
      name: control
      disk_size: 40g
      cpu: 4
      mem: 8192
      mac: 52:54:00:aa:e3:6
      vm_count: 3
    
    # COMPUTE VM
    virt_env_ospd_compute:
      name: compute
      disk_size: 40g
      cpu: 4
      mem: 4096
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
    virt_env_ospd_download_images: true
    virt_env_ospd_upload_images: false

    # BAREMETAL NODES #
    virt_env_ospd_ssh_prv: -----BEGIN RSA PRIVATE KEY-----\nPrivate key from the hypervisor\n-----END RSA PRIVATE KEY-----
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
# mkdir ~/cloud-init
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
      - ssh-pub-key
    sudo:
      - ALL=(root) NOPASSWD:ALL
  - name: root
    ssh-authorized-keys:
      - ssh-pub-key

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
EOF

# genisoimage -output /root/ansible/playbooks/virt-env-ospd/files/cloud-init-gtrellu.iso -volid cidata -joliet -rock user-data meta-data
```

Register to RHN
---------
If you don't want to use ``rho-release``, you will have to register the server to the RHN. As usual to perform this action you will need your Red Hat credentials and declare them to the playbook and then enable repositories.

**With RHN subscription, you will not be able to deploy puddle versions.**

```
rhn_username: gtrellu@redhat.com
rhn_password: xxxxxxxxxx
rhn_pool_id: 8a85f98144844aff014488d058bf15be
rhn_repos:
  - rhel-7-server-rpms
  - rhel-7-server-optional-rpms
  - rhel-7-server-extras-rpms
  - rhel-7-server-openstack-7.0-rpms
  - rhel-7-server-openstack-7.0-director-rpms
``` 

License
-------

Apache

Author Information
------------------

2016 - Gaëtan Trellu
