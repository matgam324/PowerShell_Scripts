Add-PSSnapin -Name VeeamPSSnapIn

$ImportTapes = Get-VBRTapeMedium | Where-Object { $_.IsExpired -eq $True -and $_.Location -like "Vault"-and $_.ProtectedBySoftware -eq $false} | Sort-Object -Property ExpirationDate | select -First 3 | Format-Table -Property Name | out-string

$ExportTapes = Get-VBRTapeMedium | Where-Object { $_.Location -like "Slot" -contains $_.ExpirationDate} | Sort-Object -Property ExpirationDate | select -First 3 | Format-Table -Property Name | out-string 

#SMTP server name
$smtpServer = "smtpserver.local"

#Creating a Mail object
$msg = new-object Net.Mail.MailMessage

#Creating SMTP server object
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

#Email structure
$msg.From = "User@email.com"
$msg.ReplyTo = "User@email.com"
$msg.To.Add("User@email.com")
$msg.subject = "Media Importing and Exporting Report"
$msg.body = "Move to Off-Site Store $ExportTapes", "Move to Library $ImportTapes"
$msg.Priority = 'High'

#Sending email
$smtp.Send($msg) 
