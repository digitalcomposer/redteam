---
tags: [reference, wordlists, cracking, fuzzing]
---

# Wordlists

## Location Reference (Kali/Parrot)

```bash
ls /usr/share/wordlists/
ls /usr/share/seclists/

# Install SecLists if missing
apt install seclists
```

## Password Cracking

```bash
# Tier 1: Always try first
/usr/share/wordlists/rockyou.txt                          # 14M passwords
/usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt

# Tier 2: Domain-specific
/usr/share/seclists/Passwords/Leaked-Databases/rockyou-75.txt
/usr/share/seclists/Passwords/Common-Credentials/best1050.txt

# Tier 3: Large
/usr/share/seclists/Passwords/Leaked-Databases/Ashley-Madison.txt
/usr/share/seclists/Passwords/Leaked-Databases/hak5.txt
```

## Web Fuzzing — Directories

```bash
# Balanced (start here)
/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt    # 30k entries
/usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt     # 62k entries

# Quick
/usr/share/wordlists/dirb/common.txt                                       # 4.6k entries
/usr/share/seclists/Discovery/Web-Content/common.txt                       # 4.7k entries

# Thorough
/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt       # 1.2M entries
```

## Web Fuzzing — Files

```bash
/usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt
/usr/share/seclists/Discovery/Web-Content/raft-large-files.txt

# Add extensions with ffuf: -e .php,.html,.txt,.bak,.zip,.tar.gz
```

## Web Fuzzing — Parameters

```bash
/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt
/usr/share/seclists/Discovery/Web-Content/raft-large-words.txt
```

## Username Lists

```bash
/usr/share/seclists/Usernames/Names/names.txt
/usr/share/seclists/Usernames/top-usernames-shortlist.txt
/usr/share/seclists/Usernames/xato-net-10-million-usernames.txt
```

## DNS / Subdomain Brute Force

```bash
/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt    # Fast
/usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt   # Thorough
/usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt                    # High coverage
/usr/share/seclists/Discovery/DNS/deepmagic.com-prefixes-top50000.txt
```

## Hashcat Rules (Mutation)

```bash
# Best rules
/usr/share/hashcat/rules/best64.rule
/usr/share/hashcat/rules/dive.rule
/usr/share/seclists/Passwords/Hashcat-Rules/d3adhob0.rule

# Apply rule
hashcat -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```

## Custom Wordlist Generation

```bash
# CeWL — spider a site
cewl -d 3 -m 5 -w custom.txt http://<target>
cewl -d 2 -m 4 --email -w emails.txt http://<target>

# Crunch — pattern-based
crunch 8 8 -t Password@@ -o permutations.txt   # Password01–Password99
crunch 6 8 abcdefghijklmnopqrstuvwxyz0123456789 -o alpha.txt

# CUPP — profile-based (social engineering)
python3 cupp.py -i

# Mentalist (GUI) / wordlistctl
wordlistctl list -t passwords | head
wordlistctl fetch -l rockyou
```

## Hashcat Quick Reference

```bash
# Hash type examples
hashcat -m 0    hashes.txt wordlist.txt   # MD5
hashcat -m 100  hashes.txt wordlist.txt   # SHA1
hashcat -m 1000 hashes.txt wordlist.txt   # NTLM
hashcat -m 1800 hashes.txt wordlist.txt   # SHA512crypt ($6$)
hashcat -m 13100 hashes.txt wordlist.txt  # Kerberoast (TGS)
hashcat -m 18200 hashes.txt wordlist.txt  # AS-REP Roast
hashcat -m 22000 hashes.txt wordlist.txt  # WPA2 PMKID/EAPOL
hashcat -m 2500 hashes.txt wordlist.txt   # WPA2 (legacy .hccapx)
hashcat -m 13000 hashes.txt wordlist.txt  # rar5
hashcat -m 13600 hashes.txt wordlist.txt  # zip

# Rules + mask hybrid
hashcat -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt -r best64.rule
hashcat -m 1000 hashes.txt -a 3 "?u?l?l?l?l?l?d?d"  # mask attack

# Show cracked
hashcat -m 1000 hashes.txt --show
```

## John the Ripper

```bash
# Auto-detect format
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# Specific format
john --format=NT --wordlist=rockyou.txt hashes.txt
john --format=sha512crypt --wordlist=rockyou.txt hashes.txt

# Rules
john --wordlist=rockyou.txt --rules hashes.txt

# Show cracked
john hashes.txt --show

# Useful format list
john --list=formats | grep -i ntlm
```

## Related

- [[03-Enumeration/Password-Cracking]] — Full password cracking guide
- [[00-Quick-Reference/CrackMapExec]] — Spraying with wordlists
