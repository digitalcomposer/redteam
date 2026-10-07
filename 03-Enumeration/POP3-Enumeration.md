# POP3 Enumeration (Port 110, 995)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

Post Office Protocol (POP3) - retrieves and extracts email from remote mail servers. Application layer protocol (OSI Layer 7). POP3 clients typically:
- Connect to mail server
- Retrieve all messages
- Store locally
- Delete from server

Three POP3 versions exist; POP3 is most common (port 110, 995 SSL).

## Connection

```bash
telnet $ip 110
```

## Banner Grabbing

```bash
nc -nv <IP> 110
openssl s_client -connect <IP>:995 -crlf -quiet
```

## POP3 Capabilities

Manual capability check:
```
CAPA
```

Automated enumeration:
```bash
nmap --script "pop3-capabilities or pop3-ntlm-info" -sV -p <PORT> <IP>
```

**Note:** `pop3-ntlm-info` returns sensitive data (Windows versions).

## POP3 Commands

```
USER username        # Set user
PASS password        # Set password
LIST                 # List messages
RETR <num>          # Retrieve message
DELE <num>          # Delete message
QUIT                 # Disconnect
CAPA                 # Show capabilities
```

## Related Notes

- [[03-Enumeration/SMTP-Enumeration]] → Email service enumeration
- [[03-Enumeration/MySQL-Enumeration]] → Database enumeration
- [[03-Enumeration/Password-Cracking]] → Credential attacks
