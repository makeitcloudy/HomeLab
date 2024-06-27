# in case of fresh installation of
# CentOS 6/7/8, RHEL 6/7/8
# cat /etc/centos-release
# mount the guest-tools.iso from xcp-ng or mount Citrix Hypervisor tools

mkdir /media/iso
blkid
mount /dev/sr0 /media/iso
# xcp-ng tools properly recognize the linux operating system
bash /media/iso/Linux/install.sh

# in case Citrix Hypervisor tools are used
cp /media/iso/CitrixHypervisor-LinuxGuestTools-7.20.2-1.tar.gz  .
tar -xzf CitrixHypervisor-LinuxGuestTools-7.20.2-1.tar.gz
bash LinuxGuestTools-7.20.2-1/install.sh -d centos -m 8

# disable ipv6
nmcli connection modify eth0 ipv6.method ignore

# for the modification to take effect, reboot your virtual machine
reboot

# then within the xcp-ng Center or any other console you should see in the General tab of the vm
# Virtulization state: Optimized (version 7.20 installed)
# that's it

# set proper timezone
timedatectl
ls -l /etc/localtime
timedatectl list-timezones
timedatectl set-timezone Europe/Warsaw
timedatectl

# right after that step configure the NTP client on your vm that it has proper time,
# unless you rely on vmtools synchronization
