# Demos and Deployed Azure Resources

## 1. Azure Load Balancer Deployment (Resource Group: rg-lb1-{env})

**Key Resources:**
- Virtual Machines (VMs) and OS Disks
- Load Balancer (Standard)
- Network Interfaces (NICs)
- Network Security Group (NSG)
- Virtual Network (VNet)
- Bastion Host
- Public IP Addresses
- VM Extensions (Web Server, Guest Attestation, Defender)

**Sample Resources:**
- microsoft.compute/virtualmachines: {env}-vm1, {env}-vm2, {env}-vm3
- microsoft.compute/disks: {env}-vm1_OsDisk, {env}-vm2_OsDisk, {env}-vm3_OsDisk
- microsoft.network/loadBalancers: (Standard LB)
- microsoft.network/networkInterfaces: (NICs for each VM)
- microsoft.network/networkSecurityGroups: (NSG)
- microsoft.network/virtualNetworks: (VNet)
- microsoft.network/bastionHosts: (Bastion)
- microsoft.network/publicIPAddresses: (for LB, Bastion, etc.)
- microsoft.compute/virtualmachines/extensions: GuestAttestation, InstallWebServer, MDE.Windows

## 2. Azure Application Gateway Deployment (Resource Group: rg-lb2-{env})
**Key Resources:**
- Application Gateway
- Virtual Machines (VMs) and OS Disks
- Network Interfaces (NICs)
- Public IP Addresses
- VM Extensions (IIS, Defender)

**Sample Resources:**
- microsoft.network/applicationgateways: myAppGateway
- microsoft.compute/virtualmachines: gwvm1, gwvm2
- microsoft.compute/disks: gwvm1_OsDisk, gwvm2_OsDisk
- microsoft.network/networkInterfaces: net-int1
- microsoft.compute/virtualmachines/extensions: IIS, MDE.Windows

## 3. Azure Traffic Manager Deployment (Resource Group: rg-tm-{env})
**Key Resources:**
- Traffic Manager Profile
- App Service Plans (multiple regions)
- Web Apps (multiple regions)

**Sample Resources:**
- microsoft.network/trafficmanagerprofiles: TMProfile-{env}
- microsoft.web/serverfarms: TMLabAppSvcPlan-CentralUS, TMLabAppSvcPlan-germanywestcentral, TMLabAppSvcPlan-ukwest
- microsoft.web/sites: TMLabWebApp-ldl-CentralUS, TMLabWebApp-ldl-germanywestcentral, TMLabWebApp-ldl-ukwest

---
For more information about each template and deployment, see the quickstart articles linked above.
