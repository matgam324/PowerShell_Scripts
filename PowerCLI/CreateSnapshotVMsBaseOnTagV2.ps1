[CmdletBinding()]  
  
Param(  
  
	[Parameter(Mandatory=$true,Position=1)]  
	# Asking for vCenter name
	[string]$VCenterServer,  
	
	[Parameter(Mandatory=$True,Position=3)]  
	# Asking for the name of the tag
	[string]$TagName
  
)
# connecting to vCenter server
Connect-VIServer $VCenterServer
# creating the list of VMs base on Cluster name and Tag name
$VMs = @(Get-VM -Tag $TagName)

# create Snapshot for each vm listed in $VMs
Foreach ($VM in $VMs) {

# take snapshot and give perset name and time and data when it was taken
Get-VM $VM | new-Snapshot -Name PrePatching -Description "Created $(Get-Date)" -RunAsync -Confirm:$false

}
# disconnect from vCenter server
Disconnect-VIServer * -Force -Confirm:$false