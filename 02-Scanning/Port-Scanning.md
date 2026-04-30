---
tags: [scanning, nmap, ports, discovery]
---

# Port Scanning

## Quick Workflow

```bash
# 1. Fast all-ports TCP
nmap -p- --min-rate 10000 -oN allports.txt <target>

# 2. Detailed scan on open ports
ports=$(grep "^[0-9]" allports.txt | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')
nmap -sCV -p "$ports" -oN detailed.txt <target>

# 3. UDP top ports (slow — run in background)
nmap -sU --top-ports 100 -oN udp.txt <target>
```

## Nmap Flag Reference

```bash
# Host discovery
nmap -sn <subnet>/24           # Ping sweep (no port scan)
nmap -sn -PE <subnet>/24       # ICMP echo sweep
nmap -sL <subnet>/24           # List targets (no scan)

# Scan types
nmap -sS <target>              # SYN (default, requires root)
nmap -sT <target>              # TCP connect (no root needed)
nmap -sU <target>              # UDP
nmap -sA <target>              # ACK (firewall detection)
nmap -sV <target>              # Version detection
nmap -sC <target>              # Default scripts
nmap -O <target>               # OS detection

# Speed / aggression
nmap -T1 <target>              # Sneaky (slow)
nmap -T4 <target>              # Aggressive (fast)
nmap --min-rate 5000 <target>  # Raw rate control

# Output
nmap -oN output.txt            # Normal
nmap -oG output.gnmap          # Grepable
nmap -oX output.xml            # XML
nmap -oA output                # All formats
```

## Masscan (Fastest Full-Port)

```bash
# All ports at 100k pps (adjust for network)
masscan -p1-65535 <target> --rate 100000 -oG masscan.txt
masscan -p1-65535 <subnet>/24 --rate 50000 -e eth0 -oG masscan.txt

# Parse masscan output for nmap follow-up
grep "open" masscan.txt | awk '{print $4}' | cut -d'/' -f1 | sort -un | tr '\n' ',' | sed 's/,$//'
```

## Rustscan (Fast + Nmap)

```bash
# Default (passes to nmap automatically)
rustscan -a <target> -- -sCV
rustscan -a <target> -p 1-65535 --ulimit 5000 -- -sCV -oN rustscan.txt

# Multiple targets
rustscan -a <target1>,<target2> -- -sCV
rustscan -a <subnet>/24 --ulimit 5000
```

## Common Port Quick Reference

| Port | Service | Quick Check |
|------|---------|-------------|
| 21 | FTP | `ftp <target>` / anonymous login |
| 22 | SSH | `ssh <user>@<target>` |
| 25/587 | SMTP | `swaks --to test@<domain> --server <target>` |
| 53 | DNS | `dig @<target> <domain> AXFR` |
| 80/443 | HTTP/S | `whatweb`, `ffuf`, `nikto` |
| 110/995 | POP3 | `nc <target> 110` |
| 139/445 | SMB | `smbclient`, `netexec smb` |
| 389/636 | LDAP | `ldapsearch` |
| 1433 | MSSQL | `impacket-mssqlclient` |
| 1521 | Oracle | `odat all -s <target>` |
| 3306 | MySQL | `mysql -h <target> -u root -p` |
| 3389 | RDP | `xfreerdp /v:<target>` |
| 5985 | WinRM | `evil-winrm -i <target>` |
| 6379 | Redis | `redis-cli -h <target>` |
| 8080 | Alt HTTP | web enum |
| 27017 | MongoDB | `mongosh <target>` |

## Firewall Evasion

```bash
# Fragmentation
nmap -f -sS <target>

# Decoys
nmap -D RND:10 <target>
nmap -D <decoy1>,<decoy2>,ME <target>

# Source port spoofing
nmap --source-port 53 <target>
nmap --source-port 443 <target>

# Slow scan
nmap -T1 --max-retries 1 <target>

# Append random data
nmap --data-length 25 <target>
```

## Related

- [[02-Scanning/NSE-Scripts]] — Nmap script reference
- [[02-Scanning/Service-Discovery]] — Service-specific probes
- [[00-Quick-Reference/Portscanners]] — Quick scanner cheatsheet
