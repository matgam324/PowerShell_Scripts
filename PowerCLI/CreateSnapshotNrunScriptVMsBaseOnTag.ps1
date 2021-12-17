[CmdletBinding()]  
  
Param(  
  
	[Parameter(Mandatory=$true,Position=1)]  
	# Asking for vCenter name
	[string]$VCenterServer,  
	 
	[Parameter(Mandatory=$True,Position=2)]  
	# Asking for the name of the Cluster
	[string]$ClusterName,

	[Parameter(Mandatory=$True,Position=3)]  
	# Asking for the name of the tag
	[string]$TagName
)
# connecting to vCenter server
Connect-VIServer $VCenterServer
# creating the list of VMs base on Cluster name and Tag name
$VMs = @(Get-Cluster $ClusterName| Get-VM -Tag $TagName)
# Asking for Admin Creds for the VMs 
$guestCredential = Get-Credential

# create Snapshot for each vm listed in $VMs
Foreach ($VM in $VMs) {

# take snapshot and give perset name and time and data when it was taken
Get-VM $VM | new-Snapshot -Name PrePatching -Description "Created $(Get-Date)" -RunAsync -Confirm:$false

Start-Sleep -Seconds 60

$script = "C:\Scripts\Install-WindowsUpdate.ps1"

Invoke-VMScript -VM $VM -ScriptType Powershell -ScriptText $script -GuestCredential $guestCredential


}
# disconnect from vCenter server
Disconnect-VIServer * -Force -Confirm:$false