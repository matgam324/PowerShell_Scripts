[CmdletBinding()]  
  
Param(  
  
   [Parameter(Mandatory=$True,Position=1)]  
  
   [string]$TemplateVMName,  
  
      
  
   [Parameter(Mandatory=$true,Position=2)]  
  
   [string]$VCenterServer,  

   

   [Parameter(Mandatory=$true,Position=3)]  
  
   [Security.SecureString]$TemplateAdminPassword
)  
  
Write-Output "Script started $(Get-Date)"  
 
# Check for PowerCLI  

$no = $null,"",1
If ( (Install-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $no) {  
  
    Import-Module VMware.VimAutomation.Core  
  
}  
  
Connect-VIServer $VCenterServer  
 
# Convert the template to a VM  
  
Set-Template -Template $TemplateVMName -ToVM -Confirm:$false  
  
Start-Sleep -Seconds 20  
 
# Start the VM. Answer any question with the default response  
  
Write-Output "Starting VM $TemplateVMName"  
  
Start-VM -VM $TemplateVMName | Get-VMQuestion | Set-VMQuestion -DefaultOption -Confirm:$false  
 
# Wait for the VM to become accessible after starting  
  
do   
  
{  
  
  Write-Output "Waiting for $TemplateVMName to respond...`r`n"  
  
  Start-Sleep -Seconds 10        
  
} until($ipaddress=(Get-VMGuest -VM (Get-VM -Name $TemplateVMName)).IPAddress)
(Test-Connection $ipaddress -Quiet | Where-Object { $True } )  
  
Write-Output "$TemplateVMName is up. Resting for 2 minutes to allow the VM to `"settle`"."  
  
Start-Sleep 120 # Wait additional time for the VM to "settle" after booting up  
 
# Update VMware tools if needed  
  
Write-Output "Checking VMware Tools on $TemplateVMName"
  
do   
  
{   
  
 $toolsStatus = (Get-VM $TemplateVMName | Get-View).Guest.ToolsStatus   
  
 Write-Output "Tools Status:" $toolsStatus   
  
 Start-Sleep 3   
  
 if ($toolsStatus -eq "toolsOld")   
  
 {  
  
     Write-Output "Updating VMware Tools on $TemplateVMName"  
  
     Update-Tools -VM $TemplateVMName -NoReboot  
  
 } else { Write-Output "No VMware Tools update required" }  
  
} until ( $toolsStatus -eq "toolsOk" )   
 
# Build guest OS credentials  
  
$username=".\Administrator"  
  
$password=$TemplateAdminPassword  
  
$GuestOSCred=New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password  

<#  
  
The following is the cmdlet that will invoke the Install-WindowsUpdate inside the GuestVM to install all available Windows   
  
updates; optionally results can be exported to a log file to see the patches installed and related results.  
 
#>  

$WindowsUpdate = 'Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose | Out-File C:\PSWindowsUpdate.log -Append'

Write-Output "Running PSWindowsUpdate script"  

Invoke-VMScript -ScriptText $WindowsUpdate -VM $TemplateVMName -GuestCredential $GuestOSCred | Out-file -Filepath C:\WUResults.log -Append  
    
Write-Output "Waiting 45 seconds for automatic reboot if updates were applied"  
  
Start-Sleep -Seconds 45  
    
do   
  
{  
  
  Write-Output "Waiting for $TemplateVMName to respond...`r`n"  
  
  Start-Sleep -Seconds 10        
  
} until($ipaddress=(Get-VMGuest -VM (Get-VM -Name $TemplateVMName)).IPAddress)
(Test-Connection $ipaddress -Quiet | Where-Object { $True } )  
  
Write-Output "$TemplateVMName is up. Waiting 2 hours for large updates to complete before final reboot."  
  
Start-Sleep -Seconds 7200  
 
#Restart VMGuest one more time in case Windows Update requires it and for whatever reason the â€“AutoReboot switch didnâ€™t complete it.  
  
Write-Output "Performing final reboot of $TemplateVMName"  
  
Restart-VMGuest -VM $TemplateVMName -Confirm:$false  
  
do   
  
{  
  
  Write-Output "Waiting for $TemplateVMName to respond...`r`n"  
  
  Start-Sleep -Seconds 10        
  
} until($ipaddress=(Get-VMGuest -VM (Get-VM -Name $TemplateVMName)).IPAddress)
(Test-Connection $ipaddress -Quiet | Where-Object { $True } ) 
  
Write-Output "$TemplateVMName is up. Resting for 2 minutes to allow the VM to `"settle`"."  
  
Start-Sleep 120 # Wait additional time for the VM to "settle" after booting up  
 
# Shut down the VM and convert it back to a template  
  
Write-Output "Shutting down $TemplateVMName and converting it back to a template"  
  
Shutdown-VMGuest -VM $TemplateVMName -Confirm:$false  
  
do   
  
{  
  
  Write-Output "Waiting for $TemplateVMName to shut down...`r`n"  
  
  Start-Sleep -Seconds 10        
  
} until(Get-VM -Name $TemplateVMName | Where-Object { $_.powerstate -eq "PoweredOff" } )  
  
Set-Annotation -Entity $TemplateVMName -CustomAttribute "Patched On" -Value $(Get-Date)

Set-VM -VM $TemplateVMName -ToTemplate -Confirm:$false  

Disconnect-VIServer * -Force -Confirm:$false

Write-Output "Finished updating $TemplateVMName"
  
Write-Output "Script completed $(Get-Date)".
