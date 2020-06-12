#Add the Veeam PowerShell Snapin
Add-PSSnapin -Name VeeamPSSnapIn

$IsRetired = @(Get-VBRTapeMedium | Where-Object {$_.IsRetired -eq 'True' -and $_.Location -match 'slot'})

foreach ($Retired in $IsRetired) {
write-output "Erasing Tape $($Retired.name)"
Erase-VBRTapeMedium –Medium $Retired -Long
Start-Sleep -Seconds 18000
write-output "Inventory ReFormated Tape $($Retired.name)"
Start-VBRTapeInventory –Medium $Retired
write-output "Ejecting Tape $($Retired.name)"
Eject-VBRTapeMedium –Medium $Retired
}
