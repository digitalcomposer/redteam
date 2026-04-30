# Directory Fuzzing & Path Enumeration

**Source:** gabb4r/OSCP Notes Integration

## ffuf - Fast Fuzzer

Recommended for speed and flexibility.

### Basic Directory Fuzzing

```bash
ffuf -u http://<IP>/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# Quiet mode (only results)
ffuf -u http://<IP>/FUZZ -w wordlist.txt -v

# Hide 404 responses
ffuf -u http://<IP>/FUZZ -w wordlist.txt -fc 404
```

### File Extension Fuzzing

```bash
# Test multiple extensions
ffuf -u http://<IP>/FUZZ.php -w wordlist.txt -fc 404

# Extension appending
ffuf -u http://<IP>/FUZZ -w wordlist.txt -e .php,.html,.txt -fc 404
```

### Parameter Fuzzing

```bash
# GET parameter fuzzing
ffuf -u "http://<IP>/index.php?FUZZ=test" -w wordlist.txt

# POST parameter fuzzing
ffuf -X POST -d "user=admin&FUZZ=test" -u http://<IP>/login.php -w wordlist.txt
```

### Filter Options

```bash
# Filter by status code
ffuf -u http://<IP>/FUZZ -w wordlist.txt -fc 404 -fc 403

# Filter by response size
ffuf -u http://<IP>/FUZZ -w wordlist.txt -fs 1234

# Filter by response word count
ffuf -u http://<IP>/FUZZ -w wordlist.txt -fw 45

# Match specific responses
ffuf -u http://<IP>/FUZZ -w wordlist.txt -mc 200
```

## Gobuster - Directory Brute Force

```bash
# Basic directory enumeration
gobuster dir -u http://<IP> -w wordlist.txt

# Recursive
gobuster dir -u http://<IP> -w wordlist.txt -r

# DNS subdomain brute force
gobuster dns -d domain.com -w wordlist.txt

# Virtual host enumeration
gobuster vhost -u http://<IP> -w wordlist.txt
```

## Dirbuster

GUI-based, good for visual results.

```bash
# Command line mode
dirbuster -u http://<IP> -l /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 50
```

## dirb

Traditional but reliable.

```bash
dirb http://<IP> /usr/share/wordlists/dirb/common.txt

# Custom wordlist
dirb http://<IP> /path/to/wordlist.txt

# Specific extensions
dirb http://<IP> -X .php,.html
```

## Custom Wordlists

### Generate Common Paths

```bash
# Basic fuzzing wordlist
cat << 'EOF' > paths.txt
admin
administrator
login
upload
backup
shell
test
debug
config
database
EOF
```

### CMS-Specific Paths

**WordPress:**
```
wp-admin
wp-login.php
wp-content
wp-includes
wp-json
```

**Drupal:**
```
admin
sites
modules
themes
```

**Joomla:**
```
administrator
components
modules
plugins
```

## Technique: Recursive Fuzzing

```bash
# ffuf recursive (with depth limit)
ffuf -u http://<IP>/FUZZ -w wordlist.txt -recursion -recursion-depth 3

# gobuster recursive
gobuster dir -u http://<IP> -w wordlist.txt -r
```

## Identifying Directories vs Files

```bash
# Use trailing slash to test directories
ffuf -u http://<IP>/FUZZ/ -w wordlist.txt

# Both file and directory extension patterns
ffuf -u http://<IP>/FUZZ -w wordlist.txt -e ,.php,.html
```

## Common High-Value Directories

```
/admin/
/administrator/
/login/
/user/
/upload/
/backup/
/config/
/database/
/.git/
/.svn/
/shell.php
/shell.jsp
/test.php
/debug.php
```

## Related Notes

- [[07-Web-Application/Web-Scanning]] → General enumeration
- [[07-Web-Application/CMS-Enumeration]] → CMS paths
- [[07-Web-Application/File-Upload]] → Upload vulnerability testing
