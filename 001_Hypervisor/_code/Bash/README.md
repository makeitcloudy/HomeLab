# XCP-ng - bash scripts

https://github.com/makeitcloudy/AutomatedXCPng/tree/main/bash

## XCP-ng - change the mac address of the VM

```code
# tested on 2024.11 - it works - the VM should be shutdown first

xe vm-list name-label=_debian-XO
# collect vm uuid
xe vif-list vm-uuid="VM_UUID"

# collect the:
# network UUID - 
# device number - 


xe vif-create vm-uuid="VM_UUID" network-uuid="NETWORK_UUID" mac="MAC_ADDRESS_SEPARATED_BY_COLONS" device="DEVICE_ID_NUMBER"
xe vm-start name-label=_debian-XO
```