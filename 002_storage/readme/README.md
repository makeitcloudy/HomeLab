**#Storage**
+ Once the XCP-ng or XenServer is installed (XCP-ng in context of Citrix will give you the benefit of straight access to the hypervisor API) to take the benefit of the MCS (Machine Creation Services), apart from that XCP-ng is free of charge. The only drawback I can imagine at the moment is the fact that by default, XCP-ng does not come with the XenTools for windows, so you have deal with it by utilizing the one prepared by Citrix.

**#Storage for your ISO**
+ Even though on the web there are user shares which shows that it is possible to store the ISO files directly on the Xen, it gies you limited amount of space, and won't be very helpfull at least for a citrix lab
+ Depending from your hardware you may be in disposal of NAS, or some physical external device which can play as NFS or SMB share
+ This is also feassible to setup a VM which will play as your NFS store for the ISO file, which then is mounted on Xen

+ The art of the Server - https://www.youtube.com/channel/UCKHE9DEep52XlmwLbZUKvyw
