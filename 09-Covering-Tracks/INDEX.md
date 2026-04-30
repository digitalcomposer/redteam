---
tags: [covering-tracks, index, opsec]
---

# Covering Tracks — Index

## Notes in This Section

| Note | Content |
|------|---------|
| [[09-Covering-Tracks/Linux-Log-Removal]] | bash_history, auth.log, syslog, wtmp, timestamps |
| [[09-Covering-Tracks/Windows-Log-Removal]] | wevtutil, auditpol, PowerShell logs, prefetch |
| [[09-Covering-Tracks/Artifact-Cleanup]] | Full pre-cleanup inventory, verification checklist |

## Quick Linux Cleanup

```bash
history -c && history -w
echo "" > ~/.bash_history
echo "" > /var/log/auth.log
echo "" > /var/log/syslog
# Restore file timestamps
touch -r /etc/hosts /tmp/modified-file
```

## Quick Windows Cleanup

```powershell
# Clear all event logs
wevtutil el | ForEach { wevtutil cl $_ }

# Or targeted
wevtutil cl System
wevtutil cl Security
wevtutil cl Application

# Remove files
del /f /q C:\Temp\*.exe C:\Temp\*.dll C:\Temp\*.ps1

# Disable audit logging (if admin)
auditpol /clear /y
```

## Pre-Cleanup Checklist

```
Before leaving:
[ ] List all files you dropped (note paths)
[ ] List all users you created
[ ] List all services/tasks created
[ ] List all registry keys modified
[ ] Screenshot BloodHound / netstat / ps output for report
[ ] Run cleanup: [[09-Covering-Tracks/Artifact-Cleanup]]
```

## OPSEC Reminder

Covering tracks is double-edged:
- **Pros**: reduces forensic evidence
- **Cons**: deletion itself may trigger SIEM alerts (log cleared event 1102)
- Consider whether leaving a low-noise footprint is safer than triggering "log cleared" events

## Related

- [[00-Reference/OPSEC]] — OPSEC guidance
- [[09-Methodologies/Full Checklist]] — Phase 10: Cleanup
