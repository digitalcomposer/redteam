---
tags: [enumeration, http, web, directories, vhosts]
---

# HTTP Enumeration

## Initial Fingerprint

```bash
whatweb http://<target>
curl -sI http://<target>       # Headers
curl -s http://<target>/robots.txt
curl -s http://<target>/sitemap.xml
curl -s http://<target>/.well-known/security.txt
```

## Directory/File Brute Force

```bash
# ffuf (fastest)
ffuf -u http://<target>/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
  -mc 200,301,302,403 -t 50

# With extensions
ffuf -u http://<target>/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt \
  -e .php,.html,.txt,.bak,.old,.zip,.tar.gz,.config -mc 200,301,302,403

# gobuster
gobuster dir -u http://<target> -w /usr/share/wordlists/dirb/common.txt \
  -x php,html,txt,bak -t 50 -q

# feroxbuster (recursive auto)
feroxbuster -u http://<target> -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
  -x php,html,txt -t 50 --smart-links
```

## Virtual Host Discovery

```bash
# ffuf vhost fuzz
ffuf -u http://<target>/ -H "Host: FUZZ.<domain>" \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -fs <default-response-size>

# gobuster vhost
gobuster vhost -u http://<domain> -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# wfuzz
wfuzz -c -H "Host: FUZZ.<domain>" -u http://<target>/ \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --hc 200 --hl 7
```

## Parameter Discovery

```bash
# Arjun
arjun -u http://<target>/page.php --stable -m GET
arjun -u http://<target>/page.php --stable -m POST

# ffuf parameter fuzz
ffuf -u "http://<target>/page.php?FUZZ=test" \
  -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -fs <baseline-size>

# Value fuzzing (once param found)
ffuf -u "http://<target>/page.php?id=FUZZ" \
  -w /usr/share/seclists/Fuzzing/Integers.txt -mc 200
```

## API Enumeration

```bash
# Common API paths
ffuf -u http://<target>/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt

# Swagger/OpenAPI discovery
curl http://<target>/api/swagger.json
curl http://<target>/swagger/v1/swagger.json
curl http://<target>/openapi.json
curl http://<target>/api/docs

# GraphQL
curl -X POST http://<target>/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'
```

## Authentication Bypass

```bash
# Common admin paths
/admin, /administrator, /wp-admin, /manager, /console, /dashboard
/phpmyadmin, /adminer.php, /setup.php, /install.php

# Default credentials
admin:admin, admin:password, admin:123456
root:root, test:test, guest:guest

# HTTP method override
curl -X POST http://<target>/admin -H "X-HTTP-Method-Override: GET"
```

## CMS Detection and Exploitation

```bash
# WordPress
wpscan --url http://<target> --enumerate u,p,t
wpscan --url http://<target> -U users.txt -P /usr/share/wordlists/rockyou.txt

# Drupal
droopescan scan drupal -u http://<target>

# Joomla
joomscan -u http://<target>

# Generic CMS
cmseek -u http://<target>
```

## Tech Stack Exploitation Tips

| Tech | Common Vuln | Check |
|------|-------------|-------|
| PHP | LFI, type juggling | `?file=../../../etc/passwd` |
| Java | Deserialization, SSTI | Check headers for Java |
| .NET | Viewstate deserialization | Look for `__VIEWSTATE` |
| Node.js | Prototype pollution, SSTI | `{{7*7}}`, `{{constructor.constructor('return process.env')()}}` |
| Python Flask | SSTI Jinja2 | `{{7*7}}`, `{{config}}` |
| Ruby/Rails | SSTI ERB | `<%= 7*7 %>` |

## Related

- [[07-Web-Application/SQLi]] — SQL injection
- [[07-Web-Application/XSS-SSRF-XXE-IDOR]] — XSS/SSRF/XXE
- [[00-Quick-Reference/LFI]] — LFI techniques
- [[05-Exploitation/Web-Apps]] — Web exploitation
