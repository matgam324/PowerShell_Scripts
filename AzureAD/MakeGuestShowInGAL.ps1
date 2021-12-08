if (Get-Module -ListAvailable -Name AzureAD) {
    Write-Host "AzureAD exists"
	
	Connect-AzureAD

	$ObjectIDs = Get-AzureADUser -Filter "UserType eq 'Guest'" | Select -ExpandProperty 'ObjectId'

	ForEach-Object ($ObjectID in $ObjectIDs) {
	Set-AzureADUser -ObjectId $ObjectID -ShowInAddressList $true
	}
} 
else {
    Write-Host "AzureAD does not exist run Install-Module -Name AzureAD to import"
}
