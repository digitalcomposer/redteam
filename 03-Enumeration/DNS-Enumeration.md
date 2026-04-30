# DNS Enumeration (Port 53)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

DNS enumeration identifies DNS servers and corresponding DNS records. Important record types:
- **A**: IPv4 address records
- **MX**: Mail exchange servers
- **CNAME**: Domain aliases (Canonical Name)
- **NS**: Authoritative name servers
- **SOA**: Start of Authority (zone info)
- **PTR**: Reverse DNS records
- **TXT**: Text records with administrator notes

## Whois Lookup

```bash
whois domain.com
```

## Nmap DNS Enumeration

```bash
nmap --script=dns-brute,dns-zone-transfer,dns-hostconf -p 53 <target>
```

## Host Command

### Domain Scan
```bash
host domain.com
```

### Specific Records
```bash
host -t MX domain.com
host -t NS domain.com
```

### Reverse Lookup
```bash
host <IP>
```

## Zone Transfer

DNS zone transfer (AXFR) - replicate database between DNS servers:

```bash
host -l domain.com nameserver.com
dig @nameserver domain.com AXFR
```

## Subdomain Bruteforcing

```bash
# Using host command
for i in $(cat /usr/share/seclists/Discovery/DNS/subdomains.txt); do
    host $i.domain.com | grep -v "not found"
done

# Reverse DNS lookup bruteforcing
for i in {1..254}; do host 192.168.1.$i | grep -v "not found"; done
```

## Nslookup

Interactive DNS queries:

```bash
nslookup
> server 192.168.1.1
> set type=MX
> domain.com
```

## Dig Command

### Domain Scan
```bash
dig domain.com
```

### Specific Records
```bash
dig domain.com MX
dig domain.com NS
dig domain.com TXT
```

### Reverse Lookup
```bash
dig -x 192.168.1.1
```

### Zone Transfer
```bash
dig @nameserver domain.com AXFR
```

## Automated Scanners

### Fierce
```bash
fierce -dns domain.com
```

### Dnsenum
```bash
dnsenum domain.com
```

### Dnsrecon
```bash
dnsrecon -d domain.com
```

## Sub-Domain Enumeration

### Ffuf
```bash
ffuf -w subdomains.txt -u http://domain.com -H "Host: FUZZ.domain.com"
```

### Sublist3r
```bash
sublist3r -d domain.com
```

## Related Notes

- [[02-Scanning/Port-Scanning-Enhanced]] → Initial scanning
- [[03-Enumeration/SMTP-Enumeration]] → Email server enumeration
- [[01-Reconnaissance]] → OSINT fundamentals
