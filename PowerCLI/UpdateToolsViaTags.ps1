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

do

{
    
    do

    {   
	# get the status of current VMware Tools 
    $toolsStatus = (Get-VM $VM | Get-View).Guest.ToolsStatus
    # get the last snapshot taken if there
    $snapshot = (Get-VM $VM | Get-View).snapshot.RootSnapshotList.name   
	# out put current status of the VMware Tools
    Write-Output "Tools Status: " $toolsStatus   
	# wait for 3 seconds
    sleep-seconds 3   
	# see if the statment is ture or false then follow action to match the statment
    if ($toolsStatus -eq "toolsOld" -and $snapshot -eq "PreToolsUpgrade" ) {Write-Host "Vm $vm needs snapshot $snapshot deleting and rebooting." -ForegroundColor red -BackgroundColor white; break}
		# second statment checking tool status
        elseif ($toolsStatus -eq "toolsOld")   
  
        {  
  
        Write-Output "Updating VMware Tools on $VM"  
		# take snapshot and give perset name and time and data when it was taken
        Get-VM $VM | new-Snapshot -Name PreToolsUpgrade -Description "Created $(Get-Date)" -RunAsync

        Start-Sleep -Seconds 30
		# update VMware tools without rebooting
        Update-Tools -VM $VM -NoReboot -RunAsync

        Start-Sleep -Seconds 130
                     
        }

        else { Write-Output "No VMware Tools update required on $VM" }  
		
    } until ( $toolsStatus -eq "toolsOk" ) 

}
# disconnect from vCenter server
Disconnect-VIServer * -Force -Confirm:$false
