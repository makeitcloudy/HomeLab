# RDS RDmi WVD AVD

Remote Desktop Services can have it's own separate section, it's kind of big topic. Citrix was built on top of RDS, it brings some hooks on the kernel level, added plenty of functionalities which are not available within the pure RDS (which honestly is like a russian tank, it does not offer much, but it's kind of reliable up to some extend, if only configured properly). Proper configuration may be supported by the book mentioned within the main section of AutomatedCitrix repository.
Citrix relies on protocol called HDX (ICA), where RDS is RDP based.

AVD brought much improvement and completelly changed the way of managing the product, former Server Manager console, and the RDS API, let's be honnest left much to be desired. I can not compare the RDS and Citrix - it has been done here and there over the internet, each product has it's usecases.
Does the knowledge of RDS helps a Citrix guy - yes it does.

https://github.com/tansei/AutomatedRDS

 Spin up Remote Desktop Services Session Hosts, with the regular PVS (Citrix Provisioning Services) infrastructure (https://citrixguyblog.com/2021/10/07/citrix-pvs-deploy-microsoft-remote-desktop-session-hosts-with-citrix-provisioning-services/). Please check the licensing constrains, which will help you assessing which version of the PVS you may be utilizing for the usecase. There are/were some differences..