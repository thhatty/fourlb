[comment]: <> (please keep all comment items at the top of the markdown file)
[comment]: <> (please do not change the ***, as well as <div> placeholders for Note and Tip layout)
[comment]: <> (please keep the ### 1. and 2. titles as is for consistency across all demoguides)
[comment]: <> (section 1 provides a bullet list of resources + clarifying screenshots of the key resources details)
[comment]: <> (section 2 provides summarized step-by-step instructions on what to demo)


[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Azure 4 Load Balancers Demo

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

Note: Below demo steps should be used as a guideline for doing your own demos. Please consider contributing to add additional demo steps.
</div>

### Introduction

This demo aims to deploy the 4 different load balancing solutions in Azure: Azure Load Balancer, Azure Application Gateway, Azure Traffic Manager, and Azure Front Door, and provide a short demo to showcase the fundamental features of each. These demos should provide an opportunity to explore the uses of each of these solutions, as well as some of the customization options of each. 

### 1. What Resources are getting deployed
This scenario deploys 5 different resource groups to your environment: 1 resource group for each load balancing solution, as well as a "common" rg that deploys a key vault that keeps credentials for the VM's.

**Resources created:**
- 5 Azure Resource Groups
- Key Vault
- Virtual Network (with subnets)
- Network Security Group
- Virtual Machines (with NIC, disks, and extensions)
- Public IP's
- App Services
- Load Balancing Solutions (LB, App G/W, TM, FD)
- Azure Bastion

PUT IMAGE OF RESOURCES HERE



### 2. Demonstration Steps

1. After deployment, review the created resources. You should see 5 resource groups. 

LOAD BALANCER DEMO

1) Navigate to the **Azure Load Balancer** resource. Under the **Settings** blade, go to **FrontEnd IP Configuration**. Notice that there are 2 FrontEnd IP Addresses. One for inbound traffic, and one for outbound. In this demo, traffic navigating to the VM's comes into the Inbound Public IP, and when the VM's initiate a request outbound, they use the Outbound public IP. 
2) Navigate to the **Load Balancing Rules** section, and click through the different options under "myHTTPRule". Note the **Health Probe**, and the **Session Persistence** setting. You can also showcase the **Backend Pools** section under **Settings**, and show that there are 3 VM's in the backend pools, each with a Private IP Address.
3) Navigate back to the **Frontend IP Configuration** and copy the IP Address. Paste this into your browser window and go to this IP. You should get a message from one of the 3 VM's in the backend pool. The Load Balancer is sending traffic from its Inbound IP address to the private IP address of one of the backend nodes. You can refresh a few times to get different backend nodes (it is recommended to use an incognito tab, so that the result doesn't cache. Some browsers like FireFox allow you to hold shift when refreshing the page to clear the cache. You can always close the incognito tab and then open a new one each time to ensure proper results.)
4) Navigate back to the **Load Balancing Rules** section, and set the dropdown of **Session Persistence** to "Source IP". Now, if you navigate to the IP address from before, you should get sent to the same VM, no matter how many times you refresh. 
5) Navigate to your VM in the LB Resource Group. Remote into the device using Bastion. The username is ***VMADMIN*** and the password is in the Key Vault that was created. Once in the VM, and find your IP address (For example, navigate to whatismyipaddress.com). You'll see that the IP address returned is the OutBoundIP from the FrontEndIP settings in the Load Balancer. 


APPLICATION GATEWAY DEMO
   
***
<div style="background: lightgray; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** This is the end of the current demo guide instructions.
</div>