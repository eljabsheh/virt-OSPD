virt-env-ospd
=========

This role allows you to deploy an OSP-director virtual platform.

Supported OSP-d version:

 - 7-director
 - 8-director

Requirements
------------

Ansible 2.x

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

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
          name: gtrellu_ospd7
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
            - { name: vdb, size: 10g, format: qcow2 }
            - { name: vdc, size: 10g, format: qcow2 }
            - { name: vdd, size: 10g, format: qcow2 }
          
          # CONTROL VM
          virt_env_ospd_control:
            name: control
            disk_size: 40g
            cpu: 4
            mem: 4096
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
        virt_env_ospd_upload_images: true
    
        # BAREMETAL NODES #
        virt_env_ospd_ssh_prv: -----BEGIN RSA PRIVATE KEY-----\........\n-----END RSA PRIVATE KEY-----
        undercloud_nodes:
          - { mac: "52:54:00:aa:e3:61", profile: "control" }
          - { mac: "52:54:00:aa:e3:62", profile: "control" }
          - { mac: "52:54:00:aa:e3:63", profile: "control" }
          - { mac: "52:54:00:aa:e3:81", profile: "storage" }
          - { mac: "52:54:00:aa:e3:82", profile: "storage" }
          - { mac: "52:54:00:aa:e3:83", profile: "storage" }
          - { mac: "52:54:00:aa:e3:71", profile: "compute" }
          - { mac: "52:54:00:aa:e3:72", profile: "compute" }
    
        virt_env_ospd_flavors:
          - { name: "control", ram: "8192", disk: "20", cpu: "4" }
          - { name: "compute", ram: "8192", disk: "20", cpu: "4" }
          - { name: "storage", ram: "8192", disk: "20", cpu: "4" }

License
-------

Apache

Author Information
------------------

2016 - Gaëtan Trellu
