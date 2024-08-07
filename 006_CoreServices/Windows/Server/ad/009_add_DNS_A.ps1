#Do this on the first DC
#add the DNS static records I forgot

$ZoneName = "lab.local"
Add-DnsServerResourceRecordA -AllowUpdateAny `
-CreatePtr `
-IPv4Address "192.168.1.91" `
-Name "AppLayering" `
-TimeToLive 01:00:00 `
-ZoneName $ZoneName