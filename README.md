# AutomatedCitrix

Some could say CVAD (Citrix Virtual Apps and Desktops), never the less I will stick with the first string from the product name only, as you'll neve know when the current name become the relict of the past. Where the word Citrix is still with us since 20y.

Okay so you decided to spend some time with this product, but you do not want spend too much of your precious time with setting up the vm's at first place..
1. Think of the hypervisor vendor, you'll bring into your lab. Your option may be xcp-ng (https://xcp-ng.org/). It's free, it's based on Xen.
2. Consider 10G network connectivity for your storage, then the provisioning should be much faster. Unless you got it virtualized already, and you dont' have to take care about this aspect.
3. Consider splitting your regular network for the VM traffic, that you end up with different possible scenarios for deployment (especially if you are interested with ending up with more than one site), and some specific use cases.
4. Think about the PKI infrastructure, then you can get some hands on experience with FAS (Federated Authentication Services), TLS 1.x - and you'll gain some hands on experience with openSSL, and you can take the benefit of that piece for the regular RDS (Remote Desktop Infrastructure).
5. Check the internet against the possibility of spinnig up Remote Desktop Services Session Hosts, with the regular PVS (Citrix Provisioning Services) infrastructure. Please check the licensing constrains, which will help you assessing which version of the PVS you may be utilizing for the usecase. There are/were some differences..
6. Consider the Freemium version of the Citrix Netscaler (Citrix ADC), starting version 13.0 of the product, the freemium version equals with the features previous standard releases, so it should at least give you the possibilities to get some hands on experience with SSL offloading, Load Balancing, Context switching, and some other interesting things, without a chance to set the Gateway for your CVAD infrastructure... Let's see what the 2022 bring for home labbers as Citrix is promissing some improvements in that area, and some special licenses / options.
7. Consider preparing the unattended iso's for the Server and Desktop OS'es - it will help parking aside 
