Add-PSSnapin VeeamPSSnapin

$restore_point = Get-VBRBackup | Get-VBRRestorePoint -Name "SERVER" | Sort-Object –Property CreationTime –Descending | Select-Object -First 1

$restore_start = Start-VBRWindowsFileRestore -RestorePoint $restore_point -Reason "For testing purposes"

$restore_credentials = Get-VBRCredentials -Name "Domain\VeeamServiceAccount"

$restore_session = Get-VBRRestoreSession | ?{$_.state -eq "Working" -and  $Id -eq $restore_start.MountSession.RestoreSessionInfo.Uid}

Start-VBRWindowsGuestItemRestore -Path "C:\Scripts\" -RestorePolicy Keep -Session $restore_session -GuestCredentials $restore_credentials

Stop-VBRWindowsFileRestore $restore_start
