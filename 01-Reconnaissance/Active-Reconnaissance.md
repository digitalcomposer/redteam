# Active Reconnaissance

**Tags:** #recon #enumeration #nmap #scanning
**Phase:** Information Gathering → Target Profiling

---

## 0. Engagement Setup

```bash
export TARGET="10.10.10.X"
export DOMAIN="corp.local"
export LHOST="10.10.14.X"
export DC_IP="10.10.10.1"

mkdir -p ~/engagements/$TARGET/{recon,scans,loot,exploits,screenshots}
cd ~/engagements/$TARGET
```

---

## 1. Host Discovery

```bash
# Ping sweep
nmap -sn 192.168.1.0/24 --open -oG alive.txt
grep "Up" alive.txt | awk '{print $2}' > hosts.txt

# ARP (local network — more reliable)
arp-scan --localnet
netdiscover -r 192.168.1.0/24 -i eth0

# Without ICMP (FW may block ping)
nmap -sn -PS80,443,22,445 192.168.1.0/24
nmap -sn -PA80,443 192.168.1.0/24

# Quick masscan (faster than nmap for large ranges)
masscan -p80,443,22,445,3389,8080 192.168.1.0/24 --rate=10000 -oG masscan.txt
```

---

## 2. Port Scanning

```bash
# Phase 1: Quick top-1000 ports
nmap -sV -sC -oA scans/quick $TARGET

# Phase 2: All 65535 ports
nmap -p- --min-rate 5000 -Pn -oA scans/allports $TARGET

# Phase 3: Deep scan on open ports
nmap -sC -sV -p $(grep open scans/allports.gnmap | grep -oP '\d+/open' | cut -d/ -f1 | tr '\n' ',') -oA scans/deep $TARGET

# UDP (important — often skipped)
nmap -sU --top-ports 20 -oA scans/udp $TARGET
nmap -sU -p 53,67,68,69,123,161,162,500,514,4500 -oA scans/udp_targeted $TARGET

# Aggressive (all in one — slower)
nmap -A -p- -T4 --min-rate 3000 -oA scans/aggressive $TARGET

# Stealth (SYN scan — requires root)
nmap -sS -p- --min-rate 5000 -Pn -oA scans/stealth $TARGET
```

---

## 3. Service Enumeration

### DNS (Port 53)

```bash
# Zone transfer
dig @$TARGET domain.com AXFR
host -l domain.com $TARGET

# All record types
dig @$TARGET domain.com ANY
dig @$TARGET domain.com NS
dig @$TARGET domain.com MX
dig @$TARGET domain.com TXT

# Reverse lookup
dig -x $TARGET @$TARGET

# Brute force subdomains
dnsrecon -d domain.com -t brt -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
gobuster dns -d domain.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

### FTP (Port 21)

```bash
nmap --script ftp-anon,ftp-brute,ftp-syst -p 21 $TARGET

# Manual
ftp $TARGET       # user: anonymous, pass: any@email.com
ftp -n $TARGET
> quote user anonymous
> quote pass x

# Download everything
wget -m ftp://anonymous:@$TARGET
```

### SSH (Port 22)

```bash
# Banner grab
nc -nv $TARGET 22
ssh -v $TARGET 2>&1 | grep -i "banner\|version"

# Check supported auth methods
ssh -v user@$TARGET 2>&1 | grep "Authentications"

# Default/weak credential check
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://$TARGET -t 4
medusa -u root -P /usr/share/wordlists/rockyou.txt -h $TARGET -M ssh
```

### SMB (Port 139/445)

```bash
nmap --script smb-vuln*,smb-enum-shares,smb-enum-users -p 445 $TARGET

# Enumeration
netexec smb $TARGET
smbclient -N -L //$TARGET
netexec smb $TARGET -u '' -p '' --shares
netexec smb $TARGET -u 'guest' -p '' --shares
enum4linux-ng -A $TARGET
smbmap -H $TARGET

# Connect to share
smbclient //$TARGET/SHARENAME -N
smbclient //$TARGET/SHARENAME -U username

# Download recursively
smbclient //$TARGET/SHARENAME -N -c 'recurse;prompt;mget *'

# Vulnerability check
nmap --script smb-vuln-ms17-010 -p 445 $TARGET   # EternalBlue
nmap --script smb-vuln-ms08-067 -p 445 $TARGET
```

### HTTP/HTTPS (Port 80/443/8080/8443)

```bash
# Tech detection
whatweb http://$TARGET
curl -I http://$TARGET
curl -s http://$TARGET | grep -i "generator\|powered"

# Nikto
nikto -host http://$TARGET -p 80
nikto -host https://$TARGET -p 443 -ssl

# Directory enumeration
gobuster dir -u http://$TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -x php,html,txt -t 50
ffuf -u http://$TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -fc 404,403 -t 50
feroxbuster -u http://$TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-large-words.txt

# Virtual host fuzzing
ffuf -u http://$TARGET -H "Host: FUZZ.domain.com" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs $(curl -s -o /dev/null -w "%{size_download}" http://$TARGET)

# API endpoint discovery
ffuf -u http://$TARGET/api/FUZZ -w /usr/share/seclists/Discovery/Web-Content/api/objects.txt
ffuf -u http://$TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/swagger.txt

# SSL/TLS
sslscan $TARGET:443
./testssl.sh $TARGET:443
nmap --script ssl-cert,ssl-enum-ciphers -p 443 $TARGET
```

### LDAP (Port 389/636/3268)

```bash
nmap --script ldap-rootdse -p 389 $TARGET
nmap --script ldap-brute --script-args ldap.base='cn=users,dc=corp,dc=local' -p 389 $TARGET

ldapsearch -x -H ldap://$TARGET -b '' -s base '(objectclass=*)' namingContexts
ldapsearch -x -H ldap://$TARGET -b 'DC=corp,DC=local' '(objectClass=person)'
ldapdomaindump $TARGET -o ldap_dump/
```

### MSSQL (Port 1433)

```bash
nmap --script ms-sql-info,ms-sql-config,ms-sql-empty-password,ms-sql-xp-cmdshell -p 1433 $TARGET

netexec mssql $TARGET -u sa -p ''
netexec mssql $TARGET -u sa -p sa
netexec mssql $TARGET -u '' -p '' --local-auth

# Impacket
impacket-mssqlclient sa@$TARGET
impacket-mssqlclient $DOMAIN/$USER:$PASS@$TARGET -windows-auth

# Commands after auth
SQL> SELECT name FROM sys.databases;
SQL> EXEC xp_cmdshell 'whoami';
SQL> EXEC sp_configure 'show advanced options',1; RECONFIGURE;
SQL> EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;
```

### SNMP (Port 161 UDP)

```bash
onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt $TARGET
snmpwalk -c public -v1 $TARGET
snmpwalk -c public -v2c $TARGET 1.3.6.1.2.1.25.4.2.1.2   # Running processes
snmpwalk -c public -v2c $TARGET 1.3.6.1.2.1.25.6.3.1.2   # Installed software
snmpwalk -c public -v2c $TARGET 1.3.6.1.2.1.6.13.1.3     # Open TCP ports
```

### NFS (Port 2049)

```bash
showmount -e $TARGET
nmap --script nfs-showmount,nfs-statfs,nfs-ls $TARGET

# Mount
mkdir /mnt/nfs
mount -t nfs $TARGET:/share /mnt/nfs -o nolock
ls -la /mnt/nfs

# Check for no_root_squash
cat /proc/mounts | grep nfs
```

### Redis (Port 6379)

```bash
redis-cli -h $TARGET
redis-cli -h $TARGET PING
redis-cli -h $TARGET INFO
redis-cli -h $TARGET CONFIG GET dir
redis-cli -h $TARGET KEYS *
redis-cli -h $TARGET GET <key>
```

---

## 4. Banner Grabbing

```bash
nc -nv $TARGET 80
nc -nv $TARGET 21
nc -nv $TARGET 25

# SSL services
openssl s_client -connect $TARGET:443
openssl s_client -connect $TARGET:993  # IMAPS
```

---

## 5. Automated Recon Tools

```bash
# AutoRecon (comprehensive — runs many tools in parallel)
autorecon $TARGET --only-scans-dir -o autorecon_out/

# nmapAutomator
nmapAutomator.sh $TARGET All

# Reconnoitre
reconnoitre --target $TARGET --services --discover -o recon_out/
```

---

## Related Notes

- [[01-Reconnaissance/Passive-OSINT]]
- [[00-Quick-Reference/NMAP]]
- [[02-Scanning-Enumeration/Complete-OSCP-Notes]]
- [[09-Methodologies/Full Checklist]]
