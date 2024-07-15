# SQL

## SQL - DefaultInstance

### 1. SQL - DefaultInstance -  VM provisioning

```bash
# Provision VM

# Add extra disk
/opt/scripts/vm_add_disk.sh --vmName 'a_sql01_dexp' --storageName 'node4_hdd_sdc_lsi' --diskName 'a_sql01_dexp_SDrive' --deviceId 4 --diskGB 10  --description 'a_sql01_dexp_SdataDrive'
```

Do not have to initialize the drive with PowerShell. Desired State resource from StorageDsc module handles that.


### 2. SQL - DefaultInstance - VMTools installation

```

```


###