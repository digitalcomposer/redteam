---
tags: [scanning, nmap, nse, scripts]
---

# NSE Scripts (Nmap Scripting Engine)

## Script Categories

| Category | Purpose | Example |
|----------|---------|---------|
| `auth` | Authentication bypass | `mysql-empty-password` |
| `broadcast` | Network broadcasts | `broadcast-dhcp-discover` |
| `brute` | Credential brute force | `ftp-brute` |
| `default` (-sC) | Safe, commonly useful | `http-title`, `ssh-hostkey` |
| `discovery` | Network info gathering | `dns-zone-transfer` |
| `dos` | Denial of service | Use with caution |
| `exploit` | Active exploitation | `smb-vuln-ms17-010` |
| `external` | Third-party queries | `http-google-malware` |
| `fuzzer` | Fuzzing | `dns-fuzz` |
| `intrusive` | May crash targets | `http-form-brute` |
| `malware` | Backdoor detection | `smtp-strangeport` |
| `safe` | Non-intrusive | Most default scripts |
| `version` | Version detection | `http-server-header` |
| `vuln` | Vulnerability checks | `smb-vuln*` |

## Running Scripts

```bash
# Single script
nmap --script http-title <target>

# Multiple scripts
nmap --script http-title,http-headers,http-methods <target>

# Script category
nmap --script vuln <target>
nmap --script "smb-*" <target>
nmap --script "http-* and not http-brute" <target>

# Script with arguments
nmap --script http-brute --script-args userdb=users.txt,passdb=pass.txt -p 80 <target>

# Update script database
nmap --script-updatedb
```

## Vulnerability Scripts

```bash
# SMB vulnerabilities (critical set)
nmap --script smb-vuln-ms17-010,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061 -p 445 <target>

# All vuln scripts (slow)
nmap --script vuln -p <ports> <target>

# HTTP vulnerabilities
nmap --script http-shellshock --script-args "http-shellshock.uri=/cgi-bin/test.cgi" <target>
nmap --script http-csrf,http-dombased-xss,http-stored-xss <target>

# SSL/TLS
nmap --script ssl-heartbleed,ssl-poodle,ssl-dh-params -p 443 <target>
nmap --script ssl-enum-ciphers -p 443 <target>   # Weak cipher check
```

## Service-Specific Scripts

### FTP
```bash
nmap --script ftp-anon,ftp-bounce,ftp-brute,ftp-proftpd-backdoor,ftp-vsftpd-backdoor -p 21 <target>
```

### SSH
```bash
nmap --script ssh-auth-methods,ssh-brute,ssh-hostkey,ssh-publickey-acceptance -p 22 <target>
```

### HTTP
```bash
nmap --script http-auth-finder,http-default-accounts,http-enum,http-methods \
  http-put,http-title,http-waf-detect,http-robots.txt -p 80,443,8080 <target>
```

### SMB / RPC
```bash
nmap --script smb-os-discovery,smb-security-mode,smb-enum-shares,smb-enum-users \
  smb-system-info,smb2-security-mode,msrpc-enum -p 139,445 <target>
```

### LDAP
```bash
nmap --script ldap-rootdse,ldap-search -p 389,636 <target>
```

### MSSQL
```bash
nmap --script ms-sql-info,ms-sql-config,ms-sql-dump-hashes,ms-sql-empty-password \
  ms-sql-tables,ms-sql-xp-cmdshell -p 1433 <target>
```

### MySQL
```bash
nmap --script mysql-info,mysql-databases,mysql-tables,mysql-users \
  mysql-empty-password,mysql-dump-hashes -p 3306 <target>
```

### SNMP
```bash
nmap --script snmp-brute,snmp-info,snmp-interfaces,snmp-processes \
  snmp-sysdescr,snmp-win32-shares -sU -p 161 <target>
```

### DNS
```bash
nmap --script dns-zone-transfer,dns-brute,dns-srv-enum,dns-recursion \
  --script-args "dns-brute.domain=<domain>" -p 53 <target>
```

## Script Locations

```bash
ls /usr/share/nmap/scripts/ | grep smb
locate *.nse | grep vuln
cat /usr/share/nmap/scripts/<script>.nse   # View source
```

## Related

- [[02-Scanning/Port-Scanning]] — Basic scanning
- [[02-Scanning/Service-Discovery]] — Service fingerprinting
- [[01-Reconnaissance/Active-Reconnaissance]] — Follow-up enum
