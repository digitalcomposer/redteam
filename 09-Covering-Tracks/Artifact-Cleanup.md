# Artifact Cleanup — Complete Guide

> [!DANGER]
> Reference material for explicitly authorized adversary-simulation objectives. Routine pentest cleanup must use an artifact register, exact object names, captured before-values, customer log preservation, and system-owner verification. Never run wildcard deletion or log-clearing examples as a standard cleanup procedure.

**Tags:** #covering-tracks #forensics #opsec #cleanup
**Phase:** End of Engagement → Removal of All Traces

---

## Pre-Cleanup Inventory

```
Before cleanup — document EVERYTHING you created/modified:
[ ] Files uploaded to target
[ ] Users created
[ ] Services installed
[ ] Registry keys modified
[ ] Scheduled tasks created
[ ] Cron jobs added
[ ] Firewall rules added
[ ] Tools left on disk
[ ] Persistence mechanisms installed
[ ] Network connections opened (tunnels, proxies)
```

---

## Windows Artifacts

### Files & Directories

```powershell
# Remove tools
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
Remove-Item "C:\Temp\*" -Recurse -Force -EA SilentlyContinue
Remove-Item "C:\Users\Public\*" -Recurse -Force -EA SilentlyContinue

# Secure wipe (overwrite before delete)
cipher /w:C:\Temp
sdelete.exe -p 3 evil.exe

# Prefetch, thumbnails, recent
del "C:\Windows\Prefetch\*.pf" /f /q
del "%APPDATA%\Microsoft\Windows\Recent\*" /f /q
del "%TEMP%\*" /f /q /s

# Browser cache
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue
```

### Event Logs

```cmd
wevtutil cl Security
wevtutil cl System
wevtutil cl Application
wevtutil cl "Windows PowerShell"
wevtutil cl "Microsoft-Windows-PowerShell/Operational"
```

### Registry

```cmd
# Remove persistence keys
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v BadEntry /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v BadEntry /f
```

### Users & Services

```cmd
# Remove backdoor user
net user backdoor /delete

# Remove service
sc stop EvilService
sc delete EvilService

# Remove scheduled task
schtasks /delete /tn "EvilTask" /f
```

### Network

```cmd
# Remove firewall rules
netsh advfirewall firewall delete rule name="EvilRule"

# Remove port proxy
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8080

# Kill tunnels
Get-Process chisel,ligolo,plink -EA SilentlyContinue | Stop-Process
```

---

## Linux Artifacts

### Files & Tools

```bash
shred -u /tmp/linpeas.sh /tmp/chisel /tmp/*.py /tmp/*.sh 2>/dev/null
rm -rf /tmp/.* /tmp/* /dev/shm/* 2>/dev/null
find /tmp /var/tmp -newer /etc/passwd -type f 2>/dev/null | xargs shred -u
```

### Logs

```bash
cat /dev/null > ~/.bash_history && history -c
cat /dev/null > /var/log/auth.log
cat /dev/null > /var/log/syslog
cat /dev/null > /var/log/apache2/access.log 2>/dev/null
echo '' > /var/log/wtmp
```

### Users & Cron

```bash
# Remove added user
userdel -r backdoor

# Remove cron entries
crontab -l | grep -v "beacon\|evil\|backdoor" | crontab -
sed -i '/beacon/d' /etc/crontab
```

### SSH Keys

```bash
# Remove added authorized_keys
sed -i '/kali@kali/d' ~/.ssh/authorized_keys
sed -i '/attacker/d' /root/.ssh/authorized_keys
```

### Services

```bash
systemctl disable system-update 2>/dev/null
systemctl stop system-update 2>/dev/null
rm /etc/systemd/system/system-update.service 2>/dev/null
```

### Timestamps

```bash
# Reset file timestamps to avoid "recently modified" detection
touch --reference=/bin/ls /etc/crontab   # Match legitimate file
touch -t 202001010000 /modified_file     # Arbitrary timestamp
```

---

## Memory Artifacts

```bash
# Flush disk cache (forces dirty memory to disk, clears page cache)
sync && echo 3 > /proc/sys/vm/drop_caches

# Overwrite free disk space (prevents carving)
dd if=/dev/urandom of=/tmp/noise bs=1M 2>/dev/null; rm -f /tmp/noise
```

---

## Verification Checklist

```
[ ] No added users exist (net user / cat /etc/passwd)
[ ] No backdoor processes running (ps aux / tasklist)
[ ] No listening ports from our tools (netstat -tulnp)
[ ] No persistence (cron, registry, services, startup)
[ ] Logs cleaned (last / wevtutil qe Security)
[ ] No files in /tmp, /dev/shm, C:\Temp
[ ] No firewall rules added
[ ] No port proxies active
[ ] Tunnels closed (chisel, ligolo, plink)
[ ] History cleared
[ ] Timestamps normalized on modified files
```

## Related Notes

- [[09-Covering-Tracks/Linux-Log-Removal]] — Linux logs
- [[09-Covering-Tracks/Windows-Log-Removal]] — Windows logs
- [[09-Covering-Tracks/Covering-Tracks]] — Main covering tracks note
