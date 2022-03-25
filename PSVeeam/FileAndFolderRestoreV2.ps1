Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

Add-PSSnapin VeeamPSSnapin

$restore_point = Get-VBRBackup | Get-VBRRestorePoint -Name "Server01" | Sort-Object –Property CreationTime –Descending | Select-Object -First 1

$restore_start = Start-VBRWindowsFileRestore -RestorePoint $restore_point -Reason "For testing purposes"

$restore_credentials = Get-VBRCredentials -Name "Service\Account"

$restore_session = Get-VBRRestoreSession | ?{$_.state -eq "Working" -and  $Id -eq $restore_start.MountSession.RestoreSessionInfo.Uid}

Start-VBRWindowsGuestItemRestore -Path "E:\Temp\" -RestorePolicy Keep -Session $restore_session -GuestCredentials $restore_credentials

Stop-VBRWindowsFileRestore $restore_start

start-process -NoNewWindow -filepath "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\DoScan.exe" -ArgumentList "/ScanDir \\Server01\c$\RESTORED-Temp" -Verbose | Out-File "c:\$(get-date -f yyyy-MM-dd)-Passerv07Restore.log" -Append

Remove-Item \\Server01\c$\RESTORED-Temp -Recurse -Verbose | Out-File "c:\$(get-date -f yyyy-MM-dd)-Server01Restore.log" -Append

& "C:\Scripts\FileRestoreReportLast7days.ps1"
