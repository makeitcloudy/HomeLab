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
**2.** Install CentOS
+ https://docs.centos.org/en-US/centos/install-guide/
+ https://forketyfork.medium.com/centos-8-installation-error-setting-up-base-repository-4a64e7eb2e72
+ In case you pick CentOS8 (looks like the CentOS8 reaches end of life on 31.12.2021 - https://www.centos.org/centos-linux-eol/) during the installation you are asked about the Installation source as for now (2022.03.27) put following entry as the installation source
```
https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/
```
Another option would be to download the latest release of CentOS which is supported.
+ As software installation pick Server without GUI.

**3.** Update CentOS
(2022.03.27) - for CentOS 8
```
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum update -y
yum upgrade
```

**4.** Install XCP-ng guest tools
+ login via ssh
+ list block devices
```
blkid
```
in my case it turned out to be
```
/dev/sr0: BLOCK_SIZE="2048" UUID="2021-06-23-12-19-51-00" LABEL="XCP-ng Tools" TYPE="iso9660"
```
+ create mount point
```
mkdir /media/iso 
```
+ mount CD/DVD
```
mount /dev/sr0 /media/iso/
```
or
```
mount /dev/cdrom /media/iso/
```
+ get the content of the mounted directory
```
ls /media/iso/
```
+ install guest tools
```
bash /media/iso/Linux/install.sh
```
or
```
yum install /media/iso/Linux/xe-guest-utilities-7.20.0-9.x86_64.rpm
```
+ unmount iso
```
umount /media/iso
```
**5.** Disable IPv6
```
nmcli connection modify eth0 ipv6.method ignore
```

**6.** Add extra drive for the NFS and SMB storage
+ here there is an assumption that on your management node, you have XenOrchestra or XCP-ng center installed
+ launch the GUI and add the extra drive to the vm - put at least 80GB for your further convinience, guest-tools are already installed so the drive will be immediatelly visible in the OS, in my case the drive has been added as LVM
+ list block devices and run fdisk - to see what the drive has been bound with
```
blkid
fdisk -l
```
+ create directory for the drive
```
mkdir /labdata
```
+ format filesystem (https://access.redhat.com/articles/3129891 - How to Choose Your Red Hat Enterprise Linux File System)
```
/sbin/mkfs.ext4 -L /labdata /dev/xvdb
```
+ list the drives and get it's uuid
```
ll /dev/disk/by-uuid/
```
+ edit fstab
```
nano /etc/fstab
```
+ add following line for permanent mount (https://www.howtoforge.com/reducing-disk-io-by-mounting-partitions-with-noatime)
```
UUID=[UUID from ll /dev/disk/by-uuid]       /labdata        ext4    defaults,nosuid,noatime,nodiratime      0       0
```

**6.** Create NFS Share
+ NFS share will be used to as a iso storage repository on XCP-ng<br>
+ NFS share for the XCP-ng can be running on the XCP-ng itself, never the less to make use of it, the VM will have to be run once the hypervisor is up, and once the ISO SR is already create, it will have to be repaired after each hypervisor start or reboot.<br>
+ install the nfs-utils
```
dnf install nfs-utils -y
```
+ start and enable nfs to be up across reboots
```
systemctl start nfs-server.service
systemctl enable nfs-server.service
```
+ confirm that the nfs is up
```
systemctl status nfs-server.service
```
+ indicate the version of the nfs protocol (it is visible within the second column)<br>
nfs deamon configuration: /etc/nfs.conf<br>
nfs mount configuration : /etc/nfsmount.conf <br>
```
rpcinfo -p | grep nfs
```
+ create directory for for the NFS share
```
mkdir -p /labdata/nfs_share/labIso
chmod -R 777 /labdata/nfs_share/labIso/
```
+ restart nfs service
```
restart nfs-utils.service
```
+ edit the exports file<br>
add entries for each subnet towards which you'd like to expose the nfs share<br>
it is also possible to expose the nfs share towards each client respectively<br>
**rw** - *This stands for read/write. It grants read and write permissions to the NFS share.*<br>
**sync** - *The parameter requires the writing of the changes on the disk first before any other operation can be carried out.*<br>
**no_all_squash** - *This will map all the UIDs & GIDs from the client requests to identical UIDS and GIDs residing on the NFS server.*<br>
**root_squash** - *The attribute maps requests from the root user on the client-side to an anonymous UID / GID.*<br>
```
/labdata/nfs_share/labIso/ 172.16.X.0/24(rw,sync,no_all_squash,root_squash)
/labdata/nfs_share/labIso/ 172.16.X.0/24(rw,sync,no_all_squash,root_squash)
#/labdata/nfs_share/labIso/ 172.16.X.253(rw,sync,no_all_squash,root_squash)
```
+ export the folder
**-a** - *option implies that all the directories will be exported*<br>
**-r** - *stands for re-exporting all directories and finally*<br>
**-v** - *flag displays verbose output*<br>
```
exportfs -arv
```
+ confirm the export list
```
exportfs -s
```
+ configure the firewall rules for NFS server
```
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --permanent --add-service=mountd
```
+ reload the firewall changes for the effect to take place
```
firewall-cmd --reload
```

**7.** Create SMB Share
Samba share will be convinient for transfering data between windows VM's once those are built
+ install samba package
```
dnf install samba samba-common samba-client -y
```
+ start and enable SMB service
```
systemctl start smb
systemctl enable smb
```
+ check the service status
```
systemctl status smb
```
+ create group
```
groupadd [groupName]
```
+ add user to the group (repeat this for all users who should have access to the smb shares)
```
useradd -g [groupName] [userName]
```
+ set the SMB password
```
smbpasswd -a [userName]
```
+ create private share directory
```
mkdir -p /labdata/smb_share/labIso
```
+ set the permissions and ownership on the filesystem level
```
chmod -R 0770 /labdata/smb_share/labIso
chown -R root:labusers /labdata/smb_share/labIso/

chmod -R 0770 /labdata/nfs_share/labIso
chown -R root:labusers /labdata/nfs_share/labIso/
```
+ configure SE linux context (repeat the 2nd and 3rd command for each share)
```
setsebool -P samba_export_all_ro=1 samba_export_all_rw=1
semanage fcontext -at samba_share_t "/labdata/smb_share/labIso(/.*)?"
restorecon /labdata/smb_share/labIso

semanage fcontext -at samba_share_t "/labdata/nfs_share/labIso(/.*)?"
restorecon /labdata/nfs_share/labIso
```
+ configure samba
```
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
nano /etc/samba/smb.conf
```
+ put following content into the /etc/samba/smb.conf
```
[global]
workgroup = WORKGROUP
dos charset = cp850
unix charset = ISO-8859-1

log level = 2
dns proxy = no
map to guest = Bad User
netbios name = SAMBA-SERVER
security = USER
server string = Samba Server %v
ntlm auth = true
disable spoolss = yes
min protocol = SMB2
wins support = No
#idmap config * : backend = tbd


[labIso-nfs]
comment = nfs share xenserver
inherit acls = Yes
path = /labdata/nfs_share/labIso
valid users = @[groupName] root
guest ok = no
writable = yes
browsable = yes

[labIso-smb]
comment = smb share xenserver
inherit acls = Yes
path = /labdata/smb_share/labIso
valid users = @[groupName] root
guest ok = no
writable = yes
browsable = yes
```
+ save and restart the smb service
```
systemctl restart smb
```
+ test samba configuration
```
testparm
```
+ configure firewall rules and reload firewall
```
firewall-cmd --add-service=samba --zone=public --permanent
firewall-cmd --reload
```
**8.** OpenSSL - certificates
+
