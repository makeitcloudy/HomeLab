# DSC

Consider automating the deployment of the core elements which are the backbone of your VM infrastructure, like AD, GPO's, certificates and other stuff which will come into play, especially when in disposal of 180days evaluation products. Time is passing by fast, especially when you try to keep up in balance. Stil IaC (Infrastructure as a Code) which is your goal, requires a lot of work, and it does not often scales well, but stil better than manual clicks.

## WinRM

[winRM - over HTTPS](https://gist.github.com/gregjhogan/dbe0bfa277d450c049e0bbdac6142eed)

## Domain join

* [powershellgallery.com](https://www.powershellgallery.com/packages/ComputerManagementDsc/6.2.0.0/Content/Examples%5CResources%5CComputer%5C2-JoinDomain.ps1) - Join Computer to the domain
* [Mike F Robins](https://mikefrobbins.com/2014/12/04/use-a-certificate-with-powershell-dsc-to-add-a-server-to-active-directory-without-hard-coding-a-password/) - Use a certificate with PowerShell DSC to add a server to Active Directory without hard coding a password


* [Ben Gelens series](https://bgelens.nl/integrating-vm-role-with-desired-state-configuration-part-9-create-a-domain-join-dsc-resource/)
* [Mehic.se series](https://mehic.se/2019/04/16/desired-state-configuration-dsc-get-started/)
* [youtube](https://www.youtube.com/watch?v=ht967TfzKDg) - Laptop Home Lab Set Up Part 6: Using Desired State Configuration (DSC)
