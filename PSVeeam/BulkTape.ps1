Add-PSSnapin -Name VeeamPSSnapIn

$a = (Get-VBRTapeMedium | Where-Object { $_.IsExpired -eq $True -and $_.Location -like "Vault"-and $_.ProtectedBySoftware -eq $false} | Measure-Object | Select-Object Count).count

$b = $a/3

$c = [math]::Floor($b)

1..$c | % {

	$Tapes = Get-VBRTapeMedium | Where-Object { $_.Location -like "Slot" -contains $_.ExpirationDate} | Sort-Object -Property ExpirationDate | select -First 3

	Export-VBRTapeMedium -Medium $Tapes -Wait
	
	$Shell = New-Object -ComObject "WScript.Shell"
	$Button = $Shell.Popup("Click OK to continue.", 0, "Open Mailslot", 0)

    Start-Sleep -Seconds 30
	
	$Shell = New-Object -ComObject "WScript.Shell"
	$Button = $Shell.Popup("Click OK to continue.", 0, "Mailslot Closed?", 0)
	
	}

$Shell = New-Object -ComObject "WScript.Shell"
$Button = $Shell.Popup("Swap Tapes Over Click OK to continue.", 0, "Swap Tapes Over", 0)

1..$c | % {

    $Shell = New-Object -ComObject "WScript.Shell"
	$Button = $Shell.Popup("Click OK to continue.", 0, "Load Media", 0)

    Start-Sleep -Seconds 30
    
    Get-VBRTapeLibrary -Name "HP MSL G3 Series 8.40" | Import-VBRTapeMedium -Wait

}

Start-Sleep -Seconds 60

$imported = Get-VBRTapeMedium | where {$_.IsExpired -eq 'True' -and $_.Location -match 'slot'} 

Move-VBRTapeMedium -Medium $imported -MediaPool 'Free'

$Shell = New-Object -ComObject "WScript.Shell"
$Button = $Shell.Popup("Click OK to continue.", 0, "Finished", 0)
