**#Setup NFS and SMB on CentOS for the XCP-ng Storage Repository**

**1.** Download Centos ISO (x86_64) - https://www.centos.org/download/<br>
+ As there is no ISO repository you should directly download the iso into the XCP-ng<br>
https://linuxconfig.org/how-to-add-iso-image-storage-repository-on-xenserver-7-linux
```
mkdir /var/opt/ISO_IMAGES
cd /var/opt/ISO_IMAGES
wget [pick the url from https://www.centos.org/download/mirrors/]
```
+ Create Storage repository
```
xe sr-create name-label=ISO_IMAGES_LOCAL type=iso device-config:location=/var/opt/ISO_IMAGES device-config:legacy_mode=true content-type=iso
```
+ Output will give you the UUID of the created storage repository
```
xe sr-list
```
+ List your storage repository
```
xe pbd-list sr-uuid=[UUID of the /var/opt/ISO_IMAGES]
```

**2.** Install Centos
+ https://docs.centos.org/en-US/centos/install-guide/

**3.** Create NFS Share
+ NFS share will be used to as a storage repository for the iso
+ NFS share for the XCP-ng can be running on the XCP-ng itself, never the less to make use of it, the VM will have to be run once the hypervisor is up, and once the ISO SR is already create, it will have to be repaired after each hypervisor start or reboot.

**4.** Create SMB Share
+ Samba share will be convinient for transfering data between windows VM's once those are built
