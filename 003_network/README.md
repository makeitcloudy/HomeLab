**#Network Layer**<br><br>
In case you don't yet have the skills to configure the network appropriatelly, as your experience come from different layers, it's not an issue to remain virtual within your network. At the end it may become a bit more difficult, but it all depends what you got used to. Remember that all the traffic will be processed through your compute layer and the CPU will be shared between the VM's and the network traffic. Never the less that should not be an issue for a homelab.<br>

For a home lab it's suffient, where your Management, VM traffic and Storage traffic goes over ethernet. Stick with SFP+ ports if possible, dual port cars would give you the possibilities to have more extensive scenarios for the network topology, but if the price is the case, then you can stick with sing port card, intel based or mellanox which is well recognized by the hypervisors, and desktop operating systems. If you decide to follow the type 2 virtualization with the route of vmware player or workstation.<br>

Try using the card which support SR-IOV (https://www.youtube.com/watch?v=EJyOeT0XGcA).<br>
To get some deeper network skills, you may support yourself with:
+ Eve-NG - The Network Berg gives a great introduction here (https://www.youtube.com/watch?v=nZq6bA5Cc_o&list=PLJ7SGFemsLl1ZSsdcdYqeCFDM71dz97XS)<br>
+ GNS3 - David Bombal will give you helpfull hand on youtube<br>
+ still with regular hypervisors and it's vswitches you can configure topologies which will help you as well, never the less with abovementioned products, the end user experience will be much easier, as those products are dedicated for such usecases.<br>

As it goes for the firewall the pfsense will do the trick, it can be virtualized, the only drawback is that it is fully GUI based, and I'm not aware about configuring it via console, so you have to click to make it work. But the firewall configuration in home lab does not tend to be extremely dynamic, so you'll survive. The benefits are there, for instance it can terminate your VPN, as with the Citrix ADC Freemium, if I'm not wrong you'll get option to setup 5 VPN SSL connections, where with pfsense you can get the OpenVPN, and other functionalities which comes with the plugins or are available out of the box.<br>
There are people who are towards OPNSense and there is also other groups who opt for VyOS or IpFire.<br>
Choise is your's, for a starting point you may rely on a firewall built into the operating system, and have it configured with DSC, which is very convinient way of managing the rules.<br><br>

**#Psfsense**<br><br>

+ Lawrence - pfsense playlist - https://www.youtube.com/watch?v=fsdm5uc_LsU&list=PLjGQNuuUzvmsuXCoj6g6vm1N-ZeLJso6o<br>
very much of this can be applied to the homelab, especially when there is no physical devices and the functions like firewall, routing, VPN are virtualized.<br>
