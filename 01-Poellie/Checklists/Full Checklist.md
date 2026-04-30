### ?? **Initial Enumeration**

#### ?? Nmap Scan
```bash
nmap -sC -sV -oA full_scan 10.10.X.X
nmap -p- --min-rate=1000 -oA all_ports 10.10.X.X
```
#### ?? Web
- `whatweb`, `nikto`, `gobuster`, `ffuf`
- `robots.txt`, `/dev`, `/backup`, `/admin`
- Check source code, comments, JS files
- Dirbusting with extensions: `.php`, `.bak`, `.txt`
#### ?? SMB
```bash
smbclient -L \\10.10.X.X\\ -N
enum4linux-ng -A 10.10.X.X
crackmapexec smb 10.10.X.X --shares
```
##### ?? LDAP / Kerberos
```bash
nmap -p 389,88
nmap --script ldap* -p 389 10.10.X.X
GetNPUsers.py (from Impacket) � AS-REP Roasting
```
#### ?? FTP / SSH
- Anonymous login? `ftp 10.10.X.X`
- Banner grabbing: `nc`, `telnet`

### ?? Post-Exploitation Cheat Sheet
#### ?? **Windows**
#####  ?? Recon
```cmd
whoami /priv
ipconfig /all
systeminfo
net user
net localgroup administrators
tasklist /v
```

#### ?? Credential Hunting
- `type C:\unattend.xml` / `sysprep.inf`
- `findstr /si password *.txt *.xml *.ini`
- `reg query HKLM /f password /t REG_SZ /s`

#### ?? Token Manipulation
```cmd
whoami /groups
whoami /priv
# If SeImpersonatePrivilege ? Use `Juicy Potato` / `PrintSpoofer`
```
#### ?? Tools
- `Seatbelt.exe`
- `winPEAS.exe`
- `SharpHound` ? BloodHound
- `Rubeus.exe` ? Kerberoast, AS-REP, ticket abuse
#### ?? **Linux**
#### ?? Recon
```bash
id
uname -a
hostname
ps aux
netstat -tulnp
```
#### ?? PrivEsc
```bash
sudo -l
find / -perm -4000 2>/dev/null
find / -type f -name "*pass*" 2>/dev/null
```
#### ?? Cron Jobs
```bash
cat /etc/crontab
ls -la /etc/cron.*
```
#### ?? Capabilities / Wildcard Abuse
```bash
getcap -r / 2>/dev/null
```
## Privilege Escalation Checklist

---

### ? **Windows PrivEsc**
- `whoami /priv` � SeImpersonate?
- `netstat -ano` � Interesting ports/services?
- `schtasks /query /fo LIST /v` � Any misconfigured scheduled tasks?
- Writable services (`services.msc`)
- Always look in:
    - `C:\Users\Public\`
    - `C:\ProgramData\`
    - `Downloads`, `Desktop`, etc.

### ? **Linux PrivEsc**
- `sudo -l` � Can we run anything as root?
- `pspy` � Monitor cron jobs / processes
- SUID binaries:
```bash
find / -perm -u=s -type f 2>/dev/null
```
* Check for writable scripts in cron:
```bash
ls -la /etc/cron.*
```
Exploitable binaries (GTFOBins):
- `nano`, `vim`, `less`, `awk`, `perl`, `python`, etc.

## ?? Mini Cheat Sheet (Tools & Tactics)
---
### ??? Core Tools

| Tool           | Use Case                          |
| -------------- | --------------------------------- |
| `gobuster`     | Web dir brute                     |
| `linpeas`      | Linux privesc                     |
| `winPEAS`      | Windows privesc                   |
| `pspy`         | Cron/Process watcher              |
| `smbclient`    | SMB access                        |
| `crackmapexec` | SMB/LDAP brute/enum               |
| `bloodhound`   | AD visual mapping                 |
| `Rubeus`       | Kerberoast, ticket abuse          |
| `Impacket`     | Toolkit for SMB, Kerberos, PSExec |