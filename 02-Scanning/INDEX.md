---
tags: [scanning, index]
---

# Scanning — Index

## Notes in This Section

| Note | Content |
|------|---------|
| [[02-Scanning/Port-Scanning]] | nmap, masscan, rustscan — full port discovery |
| [[02-Scanning/Service-Discovery]] | Banner grabbing, protocol probing, version detection |
| [[02-Scanning/NSE-Scripts]] | nmap script categories, vuln/service/brute scripts |

## Workflow

```bash
# Step 1: All-port TCP (fast)
nmap -p- --min-rate 10000 -oN allports.txt <target>

# Step 2: Service + script scan on open ports
ports=$(grep "^[0-9]" allports.txt | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')
nmap -sCV -p "$ports" -oN detailed.txt <target>

# Step 3: UDP top 100 (slow — background)
nmap -sU --top-ports 100 -oN udp.txt <target> &

# Step 4: Vuln scan on interesting ports
nmap --script vuln -p <interesting-ports> <target>
```

## Common Discoveries → Next Steps

| Discovery | Next Step |
|-----------|-----------|
| Port 22 (SSH) | Brute with hydra, check banners |
| Port 80/443 | Web enum → [[03-Enumeration/HTTP-Enumeration]] |
| Port 139/445 (SMB) | → [[03-Enumeration/SMB-Enumeration]] |
| Port 389/636 (LDAP) | → [[03-Enumeration/LDAP-Enumeration]] |
| Port 1433 (MSSQL) | impacket-mssqlclient |
| Port 3306 (MySQL) | mysql -h target -u root |
| Port 5985 (WinRM) | → [[00-Quick-Reference/Evil-WinRM]] |
| Port 3389 (RDP) | → [[00-Quick-Reference/xfreerdp]] |

## Related

- [[03-Enumeration/DNS-Enumeration]] — DNS recon
- [[01-Reconnaissance/Active-Reconnaissance]] — Active service probing
- [[00-Quick-Reference/Portscanners]] — Scanner quick reference
