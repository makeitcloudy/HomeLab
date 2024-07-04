# GPU Virtualization

Nvidia released drivers for GeForce GPU Passthrough for Windows Virtual Machine (Beta) (https://nvidia.custhelp.com/app/answers/detail/a_id/5173/~/geforce-gpu-passthrough-for-windows-virtual-machine-%28beta%29). If you think of going Tesla or Quaddro way you'll need extra licenses from nvidia.

## Links

### GPU Virtualization

* https://williamlam.com/2020/06/passthrough-of-integrated-gpu-igpu-for-standard-intel-nuc.html
* https://www.nvidia.com/Download/index.aspx
* https://developer.nvidia.com/cuda/wsl/download

#allows using their video cards in the Linux "super VM" while using a Windows host OS and what OP posted here
#allows using their video cards in Windows while using a Linux host OS.

* https://www.storagereview.com/news/nvidia-enables-beta-support-for-virtualization-on-geforce-gpus
* https://www.reddit.com/r/VFIO/comments/mnp8ze/vgpu_unlock_unlock_vgpu_functionality_for/
* https://gist.github.com/HiFiPhile/b3267ce1e93f15642ce3943db6e60776
* https://github.com/DualCoder/vgpu_unlock
* https://docs.google.com/document/d/1pzrWJ9h-zANCtyqRgS7Vzla0Y8Ea2-5z2HEi4X75d2Q/edit - #gpu unlock wiki
* https://looking-glass.io/wiki/Installation_on_other_distributions
* https://bestofcpp.com/repo/DualCoder-vgpu_unlock
* https://www.youtube.com/watch?v=wEhvQEyiOwI
* https://github.com/VGPU-Community-Drivers/Merged-Rust-Drivers
* https://gitlab.com/polloloco/vgpu-5.15

* (<https://discord.com/channels/829786927829745685/829786927829745688>)

```powershell
#S7150 drivers
https://www.amd.com/en/support/professional-graphics/firepro/firepro-s-series/firepro-s7150-passive-cooling

X10DRH-CT-O
https://xcp-ng.org/forum/topic/3404/firepro-s7150x2-sr-iov-errors/20
https://xcp-ng.org/docs/compute.html#vgpu

https://www.supermicro.com/support/faqs/faq.cfm?faq=15165

#Which X9 motherboards support PC-SIG SR-IOV? Can SR-IOV be enabled/disabled in BIOS 
# (or elsewhere) of every X9 motherboard which supports SR-IOV?
#Answer
#All X9 boards supported SR-IOV but the NIC which supported SR-IOV must connect to the 
#CPU PCIe ports (or add-on card from CPU PCIe slots).
#Also need to make sure the NIC EEPROM enabled SR-IOV supported. 
#Disabled VT-D can disable SR-IOV.

https://community.amd.com/t5/graphics-cards/sr-iov-and-vce/td-p/70589

https://forums.servethehome.com/index.php?threads/sr-iov-on-amd-instinct-mi25.38175/
https://pve.proxmox.com/wiki/MxGPU_with_AMD_S7150_under_Proxmox_VE_5.x

https://en.wikipedia.org/wiki/Video_Coding_Engine
```
