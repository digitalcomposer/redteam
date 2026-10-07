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
# Step 1: All-port TCP using the approved scan rate
export TARGET="192.0.2.10" SCAN_RATE="300"
mkdir -p scans
nmap -Pn -p- --min-rate "$SCAN_RATE" --max-retries 2 -oA scans/tcp-all "$TARGET"

# Step 2: Service + script scan on open ports
ports=$(awk -F/ '/^[0-9]+\/open\// {print $1}' scans/tcp-all.gnmap | paste -sd, -)
test -n "$ports" && nmap -Pn -sV -sC -p "$ports" -oA scans/tcp-services "$TARGET"

# Step 3: UDP top 100 (slow — background)
sudo nmap -Pn -sU --top-ports 100 --version-intensity 2 -oA scans/udp-top100 "$TARGET"

# Step 4: Vuln scan on interesting ports
nmap -Pn --script vuln -p "$ports" -oA scans/nse-vuln "$TARGET"
```

## Common Discoveries → Next Steps

| Discovery | Next Step |
|-----------|-----------|
| Port 22 (SSH) | Check banner, algorithms, approved credentials, then rate-limited password testing |
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
