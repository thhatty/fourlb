# Trainer Demo Deploy: Load Balancer, Application Gateway, and Traffic Manager

## Prerequisites
To run these demos, ensure you have the following installed locally:
- Azure Developer CLI (`azd`)

## Overview
This Trainer Demo Deploy template provides three Azure infrastructure demos:

1. **Azure Load Balancer Deployment**: Demonstrates a standard load balancer distributing traffic across VMs in different zones.
2. **Azure Application Gateway Deployment**: Shows an application gateway with backend VMs and network resources.
3. **Azure Traffic Manager Deployment**: Illustrates global traffic distribution using Traffic Manager and multi-region web apps.


## Architecture
Each demo provisions a set of Azure resources to illustrate core networking and traffic management concepts. Architecture diagrams and flowcharts can be found in the `demoguide` folder (add diagrams as needed).

## Deployment
1. Create a new folder for your demo environment:
   ```sh
   mkdir my-demo
   cd my-demo
   ```
2. Initialize the deployment with this template:
   ```sh
   azd init -t https://github.com/thhatty/fourlb
   ```
3. Deploy the resources:
   ```sh
   azd up
   ```

## Usage
After deployment, you can demonstrate the following scenarios:

### 1. Azure Load Balancer Demo
- Access the public IP of the load balancer to see traffic distributed across VMs.
- Use Bastion Host for secure VM access.

### 2. Azure Application Gateway Demo
- Access the Application Gateway's frontend IP to test routing and backend pool health.

### 3. Azure Traffic Manager Demo
- Use the Traffic Manager DNS name to observe global traffic distribution and failover.

- ### 3. Azure Front Door Demo
- Use the Front Door to observe CDN Caching.

Refer to the `demoguide/demoguide.md` for detailed, step-by-step instructions for each demo.

## Deployed Azure Resources

### Azure Load Balancer Deployment (Resource Group: rg-lb1-{env})
- Virtual Machines (VMs) and OS Disks
- Load Balancer (Standard)
- Network Interfaces (NICs)
- Network Security Group (NSG)
- Virtual Network (VNet)
- Bastion Host
- Public IP Addresses
- VM Extensions (Web Server, Guest Attestation, Defender)

### Azure Application Gateway Deployment (Resource Group: rg-lb2-{env})
- Application Gateway
- Virtual Machines (VMs) and OS Disks
- Network Interfaces (NICs)
- Public IP Addresses
- VM Extensions (IIS, Defender)

### Azure Traffic Manager Deployment (Resource Group: rg-tm-{env})
- Traffic Manager Profile
- App Service Plans (multiple regions)
- Web Apps (multiple regions)

### Azure Front Door Deployment (Resource Group: rg-fd-{env})
- Front Door Profile
- Storage Account
- App Service


## Contributing
Contributions to enhance these demos are welcome. Please submit issues and pull requests.

## License
This project is licensed under the MIT License.

## About
This repository contains Trainer Demo Deploy templates for Azure networking and traffic management scenarios. For more information, see the `demoguide` folder and Azure Quickstart documentation.
