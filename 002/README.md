**#Network Layer**<br><br>
In case you don't yet have the skills to configure the network appropriatelly, as your experience come from different layers, it's not an issue to remain virtual within your network. At the end it may become a bit more difficult, but it all depends what you got used to. Remember that all the traffic will be processed through your compute layer and the CPU will be shared between the VM's and the network traffic. Never the less that should not be an issue for a homelab.<br>

For a home lab it's suffient, where your Management, VM traffic and Storage traffic goes over ethernet. Stick with SFP+ ports if possible, dual port cars would give you the possibilities to have more extensive scenarios for the network topology, but if the price is the case, then you can stick with sing port card, intel based or mellanox wchih is well recognized by the hypervisors, and desktop operating systems if you decide to follow the type 2 virtualization with the route of vmware player or workstation.<br>

Try using the card which support SR-IOV.
