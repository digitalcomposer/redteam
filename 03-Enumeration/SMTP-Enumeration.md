# SMTP Enumeration (Port 25)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- Simple Mail Transfer Protocol
- Used to send, receive, and relay outgoing emails
- Default port: 25
- Main attacks: User enumeration, open relay exploitation

## NSE Scripts

```bash
nmap 192.168.1.101 --script=smtp* -p 25
nmap --script=smtp-commands,smtp-enum-users,smtp-vuln-cve2010-4344 -p 25 $ip
```

## User Enumeration

```bash
smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt -t $ip

# For multiple servers
for server in $(cat smtpmachines); do
    echo "Server: $server"
    smtp-user-enum -M VRFY -U userlist.txt -t $server
done
```

## Connection & Banner Grabbing

```bash
telnet $ip 25
nc -nv <IP> 25
openssl s_client -connect <IP>:25 -crlf -quiet
```

## SMTP Commands

### Check User Exists
```
VRFY username
```

### Mailing List Check
```
EXPN mailing_list_name
```

## Brute Force Credentials

```bash
hydra -l user -P /usr/share/wordlists/rockyou.txt $ip smtp
```

## Send Email Using Netcat

```bash
(echo "EHLO test"; sleep 1; echo "MAIL FROM:<sender@example.com>"; sleep 1; echo "RCPT TO:<recipient@example.com>"; sleep 1; echo "DATA"; sleep 1; echo "Subject: Test"; echo ""; echo "Test message"; sleep 1; echo "."; echo "QUIT") | nc -q 1 $ip 25
```

## Related Notes

- [[03-Enumeration/DNS-Enumeration]] → Domain information gathering
- [[03-Enumeration/Password-Cracking]] → Authentication attacks
