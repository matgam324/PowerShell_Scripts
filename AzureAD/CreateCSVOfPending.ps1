Connect-AzureAD

Get-AzureADUser -all $true | Where-Object {($_.Userstate -eq 'PendingAcceptance') -and ($_.UserStateChangedOn -like '2022-03-02*') } | Select-Object mail | ConvertTo-csv -NoTypeInformation | Out-File "C:\PendingAcceptance01.csv"

Disconnect-AzureAD
