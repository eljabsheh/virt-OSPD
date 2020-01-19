# 1) What this playbook is about

This playbook creates several VMs and networks to provide the 'skeleton' upon which a fully virtualized Red Hat Openstack Platform deployment (**RHOSP**) may be built.

# 2) What it provides
After running this playbook, you will get:
- One Undercloud VM installed with **RHEL7** or **RHEL8** (RHOSP15 and RHOSP16)
- Sixteen (16) baremetal VMs to use for your undercloud.
- Virtual networks which attempt to closely match what is found in baremetal deployments.

# 3) Networking setup

This section describes the networking setup configured for the VMs.
- - Undercloud :
  * nic0 : provisioning - abstracted to 'bond0'
  * nic1 : internal network to overcloud (bridge net-full) - abstracted to 'bond1'
  * nic2 : virbr0 (192.168.122.x), needed for adding stack user, keys, directories, instackenv,json, etc..  - abstracted to 'bond2'
  * nic3 : external network (allowed use of the Director UI when it was still a thing)  - abstracted to 'bond3'

- Overcloud controllers:
  * nic0 : provisioning
  * nic1 : internal network (bridge net-full)
  * nic2 : internal network (bridge net-full), bonded with nic2
  * nic3 : external network (allows use of Horizon/API for things like SAF, Dynatrace, etc..)

- Overcloud computes:
  * nic0 : provisioning
  * nic1 : internal network (bridge net-full)
  * nic2 : internal network (bridge net-full), bonded with nic2
  * nic3 : unused

- Overcloud Ceph Storage, Swift Storage:
  * nic0 : provisioning
  * nic1 : internal network (bridge net-full)
  * nic2 : internal network (bridge net-full), bonded with nic2
  * nic3 : internal storage-only network


# 4) Requirements

This playbook requires the following:
- Must be run -on- the hypervisor which will host your VMs
- Edit the playbooks under playbooks/virt-env-ospd to change defaults
- The user executing the playbook on the hypervisor must have 'libvirtd' access.


# 5) How to use.

As a non-privileged user (preferred), change to the playbook directory and execute ```./launch.sh```

This will present you with a plain menu to select two answers:
- What **RHOSP** version is desired.
- How much memory is present on your Hypervisor (required to create VMs)

```
(II) Here are some suggestions for your systems:
----------------------------------------------
 - ravenvale            : 64G config or 'ravenvale' config
 - daltigoth            : 128G config or 'daltigoth' config
 - palanthas            : 192G config or 'palanthas' config
 - thorbardin           : 256G config or 'thorbardin' config
----------------------------------------------
1) 8
2) 9
3) 10
4) 11
5) 12
6) 13
7) 15
8) 16
(II) Please select an OSP version: 7
1) 32G           3) 128G         5) 192G         7) daltigoth    9) thorbardin
2) 64G           4) 160G         6) 256G         8) palanthas   10) ravenvale
(II) Please select memory config for your hypervisor: 7
```

Once executed successfully, you should obtain the following VM family:
```
[root@daltigoth ~]# virsh list --all|egrep 'instack|overc'
 -     instack-15                     shut off  <========== Undercloud node
 -     overcloud-ceph-0               shut off
 -     overcloud-ceph-1               shut off
 -     overcloud-ceph-2               shut off
 -     overcloud-ceph-3               shut off
 -     overcloud-compute-0            shut off
 -     overcloud-compute-1            shut off
 -     overcloud-compute-2            shut off
 -     overcloud-compute-3            shut off
 -     overcloud-compute-4            shut off
 -     overcloud-compute-5            shut off
 -     overcloud-control-0            shut off
 -     overcloud-control-1            shut off
 -     overcloud-control-2            shut off
 -     overcloud-swift-0              shut off
 -     overcloud-swift-1              shut off
 -     overcloud-swift-2              shut off

```

Login to the undercloud as root from the hypervisor over the 'virbr0' network (192.168.122.x/24) and get ready to install **RHOSP**.
