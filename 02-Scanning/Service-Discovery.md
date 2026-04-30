---
tags: [scanning, services, fingerprinting, banners]
---

# Service Discovery

## Banner Grabbing

```bash
# Netcat
nc -nv <target> <port>

# Telnet (for cleartext protocols)
telnet <target> <port>

# Curl (HTTP)
curl -sv http://<target>/ 2>&1 | head -30

# OpenSSL (HTTPS / TLS)
openssl s_client -connect <target>:443 -quiet 2>/dev/null | head -5
echo | openssl s_client -connect <target>:443 2>/dev/null | openssl x509 -noout -text

# Grab banner and quit
echo "" | nc -w2 <target> <port>
```

## Nmap Service Detection

```bash
# Version detection intensity (0=light, 9=aggressive)
nmap -sV --version-intensity 5 <target>
nmap -sV --version-all <target>   # Try every probe

# Service scan specific port
nmap -sV -p 22,80,443 <target>
nmap -sCV -p <ports> <target>     # Version + default scripts

# OS detection
nmap -O --osscan-guess <target>
nmap -A <target>  # Aggressive: OS, version, scripts, traceroute
```

## Protocol-Specific Fingerprinting

### FTP (21)
```bash
nc -nv <target> 21              # Banner grab
ftp <target>                    # Try anonymous
lftp <target>                   # Alternative client
nmap --script ftp-anon,ftp-bounce,ftp-syst -p 21 <target>
```

### SSH (22)
```bash
ssh -v <target> 2>&1 | head -20 # Negotiation details
ssh-audit <target>              # Algorithm audit
nmap --script ssh-auth-methods,ssh-hostkey -p 22 <target>
```

### SMTP (25/587/465)
```bash
nc -nv <target> 25
EHLO attacker.com              # List capabilities
VRFY root                      # User enumeration
EXPN admin                     # Alias expansion
nmap --script smtp-enum-users,smtp-open-relay -p 25 <target>
smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/Names/names.txt -t <target>
```

### HTTP/HTTPS (80/443/8080/8443)
```bash
whatweb http://<target>
nikto -h http://<target>
curl -sI http://<target>
# Check: Server, X-Powered-By, Set-Cookie, Content-Type headers
```

### MySQL (3306)
```bash
nc -nv <target> 3306            # Banner shows version
mysql -h <target> -u root -p
nmap --script mysql-info,mysql-databases,mysql-empty-password -p 3306 <target>
```

### MSSQL (1433)
```bash
nmap --script ms-sql-info,ms-sql-config,ms-sql-empty-password -p 1433 <target>
impacket-mssqlclient <user>@<target> -windows-auth
```

### RDP (3389)
```bash
nmap --script rdp-enum-encryption,rdp-vuln-ms12-020 -p 3389 <target>
ncrack -vv --user Administrator -P /usr/share/wordlists/rockyou.txt rdp://<target>
```

### Redis (6379)
```bash
redis-cli -h <target>
redis-cli -h <target> -a <password>
redis-cli -h <target> info         # No auth → full info dump
redis-cli -h <target> config get * # Config
redis-cli -h <target> keys "*"     # List all keys
```

### MongoDB (27017)
```bash
mongosh <target>:27017
# In shell:
show dbs; use <db>; show collections; db.<collection>.find()
nmap --script mongodb-info,mongodb-databases -p 27017 <target>
```

### SNMP (161 UDP)
```bash
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt <target>
snmpwalk -v2c -c public <target>
snmp-check <target> -c public
```

## Automated Multi-Service

```bash
# AutoRecon (comprehensive)
autorecon <target> --single-target

# Reconnoitre (targeted)
reconnoitre -t <target> -o /tmp/recon --services

# Legion (GUI)
legion &  # GUI-based
```

## Service Version → Exploit Mapping

```bash
# After collecting versions from nmap output
searchsploit "<service> <version>"
searchsploit -x <exploit-id>    # Examine exploit

# Example
searchsploit "OpenSSH 7.4"
searchsploit "Apache 2.4.49"   # CVE-2021-41773 path traversal

# MSF search
msfconsole -q -x "search <service> <version>"
```

## Related

- [[02-Scanning/Port-Scanning]] — Port discovery first
- [[02-Scanning/NSE-Scripts]] — Script reference
- [[01-Reconnaissance/Active-Reconnaissance]] — Service-specific enum
