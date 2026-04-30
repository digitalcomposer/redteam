# Passive OSINT

**Tags:** #osint #recon #passive
**Phase:** Pre-Engagement → Target Profiling

---

## 0. Setup

```bash
export TARGET_DOMAIN="corp.com"
export TARGET_ORG="Company Inc"
export TARGET_RANGE="X.X.X.X/24"
```

---

## 1. Domain & DNS

```bash
# WHOIS
whois $TARGET_DOMAIN
whois $TARGET_RANGE

# DNS records
dig $TARGET_DOMAIN ANY
dig $TARGET_DOMAIN NS
dig $TARGET_DOMAIN MX
dig $TARGET_DOMAIN TXT   # SPF, DMARC, DKIM — reveals infra
dig $TARGET_DOMAIN AAAA  # IPv6

# Zone transfer attempt (still works on misconfigured DNS)
dig @ns1.$TARGET_DOMAIN $TARGET_DOMAIN AXFR

# Certificate transparency (find subdomains without brute force)
curl -s "https://crt.sh/?q=%25.$TARGET_DOMAIN&output=json" | jq '.[].name_value' | sort -u
```

---

## 2. Subdomain Enumeration

```bash
# Passive (no direct contact with target)
subfinder -d $TARGET_DOMAIN -o subdomains.txt
amass enum -passive -d $TARGET_DOMAIN -o amass_passive.txt
assetfinder --subs-only $TARGET_DOMAIN
findomain -t $TARGET_DOMAIN

# Certificate transparency
python3 ct-exposer.py -d $TARGET_DOMAIN

# Combine + deduplicate
cat subdomains.txt amass_passive.txt | sort -u > all_subs.txt

# Resolve to find live hosts
httpx -l all_subs.txt -o live_subs.txt
```

---

## 3. Google Dorking

```bash
# Index exposure
site:$TARGET_DOMAIN filetype:pdf
site:$TARGET_DOMAIN filetype:xls OR filetype:xlsx
site:$TARGET_DOMAIN filetype:doc OR filetype:docx
site:$TARGET_DOMAIN filetype:txt
site:$TARGET_DOMAIN filetype:sql
site:$TARGET_DOMAIN filetype:log
site:$TARGET_DOMAIN filetype:conf
site:$TARGET_DOMAIN filetype:env
site:$TARGET_DOMAIN filetype:xml

# Login pages
site:$TARGET_DOMAIN inurl:admin
site:$TARGET_DOMAIN inurl:login
site:$TARGET_DOMAIN inurl:portal
site:$TARGET_DOMAIN inurl:dashboard

# Sensitive info
site:$TARGET_DOMAIN "password"
site:$TARGET_DOMAIN "api_key" OR "api key"
site:$TARGET_DOMAIN "BEGIN RSA PRIVATE KEY"
site:$TARGET_DOMAIN "DB_PASSWORD"

# Git exposure
site:$TARGET_DOMAIN inurl:.git
"$TARGET_DOMAIN" ext:sql

# Camera / IoT
intitle:"webcam 7" inurl:'/viewer/live/index.html'
intitle:"Network Camera" inurl:$TARGET_DOMAIN
```

---

## 4. GitHub Recon

```bash
# Search GitHub for company name, domain, leaked creds
# Manual searches:
# "$TARGET_DOMAIN" password
# "$TARGET_DOMAIN" api_key
# "$TARGET_DOMAIN" secret
# org:CompanyName filename:.env
# org:CompanyName filename:config.php

# Automated tools
gitrob scan $TARGET_ORG
truffleHog git https://github.com/company/repo

# Search across GitHub
gh search code "$TARGET_DOMAIN password" --limit 100
gh search code "api.corp.com" --limit 100
```

---

## 5. Shodan / Censys / FOFA

```bash
# Shodan CLI
shodan search "org:$TARGET_ORG"
shodan search "hostname:$TARGET_DOMAIN"
shodan search "ssl:$TARGET_DOMAIN"
shodan search "ip:$TARGET_RANGE"
shodan host $TARGET_IP

# Shodan dorks
shodan search 'org:"$TARGET_ORG" port:8080'
shodan search 'ssl.cert.subject.cn:"$TARGET_DOMAIN"'
shodan search 'hostname:"$TARGET_DOMAIN" product:"Apache"'

# Censys (via browser or API)
# ip: X.X.X.X
# parsed.names: domain.com
# autonomous_system.name: "Company Inc"

# FOFA (Chinese OSINT)
# domain="corp.com"
# org="Company Inc"
```

---

## 6. Email & Employee Harvesting

```bash
# Email harvesting
theHarvester -d $TARGET_DOMAIN -b google,bing,linkedin,twitter -l 200
hunter.io (manual — find email format)
emailhippo.com (validate emails)

# LinkedIn scraping
python3 linkedin2username.py -u linkedin_user -c "Company Inc" -n 5 -s

# Generate username lists from employee names
./namemunge.py names.txt  # generates firstlast, flast, f.last, etc.
python3 linkedin2username.py -c "Company Name" > employees.txt

# Common formats to try
firstname.lastname@corp.com
flastname@corp.com
firstname_lastname@corp.com
firstnamel@corp.com
f.lastname@corp.com

# Username list generator
python3 -c "
names = [('John', 'Smith'), ('Jane', 'Doe')]
for f,l in names:
    print(f'{f.lower()}.{l.lower()}')
    print(f'{f[0].lower()}{l.lower()}')
    print(f'{f.lower()}')
"
```

---

## 7. Breached Credentials

```bash
# Check hashes / emails
# haveibeenpwned.com (API)
curl -s "https://haveibeenpwned.com/api/v3/breachedaccount/email@corp.com" \
  -H "hibp-api-key: YOUR_KEY"

# Dehashed (paid)
# Leakcheck.io
# Snusbase

# Check if target email/domain in known dumps
# Search paste sites:
site:pastebin.com "$TARGET_DOMAIN"
site:paste.ee "$TARGET_DOMAIN"
```

---

## 8. Company Infrastructure Mapping

```bash
# ASN lookup
whois -h whois.radb.net '!gAS12345'
amass intel -asn 12345

# IP range discovery
amass intel -org "$TARGET_ORG"
shodan search "org:$TARGET_ORG" --fields ip_str | sort -u > ips.txt

# Reverse IP lookup (find other sites on same server)
hackertarget.com/reverse-ip-lookup/?q=$TARGET_IP

# Cloud storage buckets
awsbucketdump -n $TARGET_DOMAIN
grayhatwarfare.com (search S3 buckets)
# Manual:
curl https://s3.amazonaws.com/$TARGET_DOMAIN/
curl https://$TARGET_DOMAIN.s3.amazonaws.com/
```

---

## 9. Technology Fingerprinting

```bash
# Without visiting target
# WhatRuns browser extension
# Built With: builtwith.com
# Wappalyzer: wappalyzer.com

# From response headers (passive)
curl -s -I https://$TARGET_DOMAIN | grep -i "x-powered-by\|server\|x-generator"

# From job postings (reveals tech stack)
# LinkedIn, Indeed job postings for company → find technologies used
```

---

## 10. Social Engineering Targets

```bash
# Find executives / privileged users
linkedin.com/company/company-name → People section

# Common high-value targets
# IT admins, sysadmins, helpdesk (password resets)
# Finance (wire transfers, invoice fraud)
# C-suite (authority in phishing)

# Email format from company website
info@, support@, helpdesk@, admin@, webmaster@
```

---

## Passive OSINT Mindmap

```
Target
├── Domain
│   ├── WHOIS → registrar, contacts, IPs
│   ├── DNS → MX, TXT, NS, subdomains
│   ├── CT Logs → all subdomains ever issued certs
│   └── Zone Transfer → full DNS dump (misconfiguration)
├── Infrastructure
│   ├── Shodan/Censys → open ports, banners, certs
│   ├── ASN → IP ranges
│   └── Cloud buckets → S3, Azure Blob, GCS
├── People
│   ├── LinkedIn → employees, roles, titles
│   ├── Email harvesting → theHarvester
│   └── Breached data → dehashed, HIBP
└── Code
    ├── GitHub → leaked keys, internal infra
    ├── Pastebin → leaked configs
    └── Job postings → tech stack
```

---

## Related Notes

- [[01-Reconnaissance/Active-Reconnaissance]]
- [[00-Quick-Reference/OSINT]]
- [[09-Methodologies/Full Checklist]]
