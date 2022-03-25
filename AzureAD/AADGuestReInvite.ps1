Connect-AzureAD

$GuestReInvites = Get-AzureADUser -all $true | Where-Object {($_.Userstate -eq 'PendingAcceptance') -and ($_.UserStateChangedOn -like '2022-03-02*') } | Select-Object -ExpandProperty Mail

foreach ($GuestReInvite in $GuestReInvites) { New-AzureADMSInvitation -InvitedUserEmailAddress $GuestReInvite -InviteRedirectURL "https://myapps.microsoft.com" -SendInvitationMessage $true}

Disconnect-AzureAD
