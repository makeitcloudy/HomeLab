Centos will play the role of NFS and SMB share, as well as the place where the self signed certificates will be created.<br><br>
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
This option should give you enough space to have one iso, which is your starting point for the NFS share, which will play a role of your NFS ISO Storage Repository for the further VM provisioning the the ISO files storage.
Default location where the guest tools are located is:
```
/opt/xensource/packages/iso/
```
**2.** Install Centos
+ https://docs.centos.org/en-US/centos/install-guide/
+ https://forketyfork.medium.com/centos-8-installation-error-setting-up-base-repository-4a64e7eb2e72
+ In case you pick CentOS8 (looks like the CentOS8 reaches end of life on 31.01.2022) during the installation you are asked about the Installation source as for now (2022.03.27) put following entry as the installation source
```
https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/
```
Another option would be to download the latest release of CentOS which is supported.
+ As software installation pick Server without GUI.

**3.** Install XCP-ng guest tools

**4.** Create NFS Share
+ NFS share will be used to as a storage repository for the iso
+ NFS share for the XCP-ng can be running on the XCP-ng itself, never the less to make use of it, the VM will have to be run once the hypervisor is up, and once the ISO SR is already create, it will have to be repaired after each hypervisor start or reboot.

**5.** Create SMB Share
+ Samba share will be convinient for transfering data between windows VM's once those are built

**6.** OpenSSL - certificates
+
