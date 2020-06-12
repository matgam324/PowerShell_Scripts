Add-PSSnapin -Name VeeamPSSnapIn

Get-VBRTapeLibrary -Name "HP MSL G3 Series 8.40" | Import-VBRTapeMedium

Start-Sleep -Seconds 240

$imported = Get-VBRTapeMedium | where {$_.IsExpired -eq 'True' -and $_.Location -match 'slot'} 

Move-VBRTapeMedium -Medium $imported -MediaPool 'Free'
