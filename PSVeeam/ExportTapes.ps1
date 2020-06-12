Add-PSSnapin -Name VeeamPSSnapIn

$Tapes = Get-VBRTapeMedium | Where-Object { $_.Location -like "Slot" -contains $_.ExpirationDate} | Sort-Object -Property ExpirationDate | select -First 3

Export-VBRTapeMedium -Medium $Tapes
