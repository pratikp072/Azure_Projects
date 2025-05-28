## Objective:
Host a web app using multiple VMs behind a Load Balancer with an availability set to ensure high availability and resiliency.

## Resources Used:
- Azure Virtual Machines (VMs)
- Availability Sets
- Network Security Groups (NSG)
- Azure Load Balancer (Public, Standard SKU)
- Virtual Network & Subnet
- Azure Monitor (for metrics and alerts)

## Step-by-Step Guide:
### ✅ Step 1: Create Resource Group (PowerShell)

### ✅ Step 2: Create virtual network and subnet (PowerShell)

### ✅ Step 3: Create availability set (PowerShell)

### ✅ Step 4: Create NSG rules-HTTP and RDP (PowerShell)

### ✅ Step 5: Deploy 2 VMs in availability set with create Public IP Address, create NIC, attach NSG to NICs (PowerShell)

### ✅ Step 6: Install IIS on Each VM via Server Manager using RDP
Open Server Manager --> Add Roles and Features --> Role-based or feature-based installation --> Web Server(IIS) --> Install

### ✅ Step 7: Modify Default IIS Web Page (to Identify VMs)
On Each VM go to: 
`C:\inetpub\wwwroot\iisstart.png`
- Open iisstart.png in **Paint** app 
- Add a label of VM names on Each
- save and close

### ✅ Step 8: Open the Public IP address of each VM in a browser to confirm IIS is running and shows the correct identifier.

### ✅ Step 9: Configure a Load Balancer
- Create a Public Load Balancer (Standard SKU)
- Create a Frontend IP Configuration
- Add VM1 and VM2 to the Backend Pool
- Create a Health Probe on port 80 (HTTP)
- Load Balancing Rules 

### ✅ Step 10: Test Load Balancing
- Copy the Frontend Public IP address from the Load Balancer and paste it into your browser.
- You should see the default IIS web page from either VM1 or VM2.
  
**To test failover:**

- stop VM1 in the Azure Portal.
- Refresh the browser. traffic should now be routed to VM2

### ✅ Step 11: Monitor & Alert on CPU Usage (Azure Portal)
- Go to the VM (e.g., WebVM1) → Monitoring > Insights
- If not enabled, click Enable Monitoring
- Go to Alerts > + Create > Alert Rule
  
**Under Condition:**

- Choose Metric: Percentage CPU
- Set logic: Greater than 80% (Average over 5 minutes)
  
**Create an Action Group:**

- Add your email/SMS under Notifications
- Name the alert (e.g., “High CPU Alert”), select severity, and click Create
- Repeat for VM2 or use Log Analytics to monitor both. (Optional)
