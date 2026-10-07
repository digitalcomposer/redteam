# Ultimate Pentest Checklist

**Tags:** #methodology #checklist #pentest
**Use:** Walk through phase by phase — check each item, log findings

---

## Phase 0 — Pre-Engagement

```
[ ] Rules of Engagement (RoE) agreed and signed
[ ] Scope defined: IP ranges, domains, applications, exclusions
[ ] Testing window established
[ ] Tester source IPs, packet rate, concurrency, and excluded networks approved
[ ] High-impact technique matrix completed
[ ] Evidence encryption, transfer, retention, and deletion agreed
[ ] Deconfliction channel and stop word tested
[ ] Emergency contacts noted (abort condition)
[ ] VPN / jump host configured
[ ] Lab environment set up (Obsidian, note-taking, screenshots)
[ ] Export variables: LHOST, RHOST, DOMAIN, DC_IP
```

---

## Phase 1 — Passive Reconnaissance

```
[ ] WHOIS: whois domain.com
[ ] DNS records: dig domain.com ANY
[ ] Subdomain enumeration: amass, subfinder, dnsrecon
[ ] Google dorking:
    [ ] site:domain.com filetype:pdf/xls/doc
    [ ] site:domain.com inurl:admin/login/panel
    [ ] site:domain.com "password" OR "username"
    [ ] "domain.com" ext:sql OR ext:env OR ext:log
[ ] Shodan/Censys/FOFA search: org:"company", ssl:domain.com
[ ] GitHub search: "domain.com" api_key, password, secret
[ ] LinkedIn: employee names → username list generation
[ ] Pastebin/breach data check (dehashed, haveibeenpwned)
[ ] Email format discovery → generate username list
[ ] Certificate transparency: crt.sh, censys.io
[ ] WAF/CDN detection: wafw00f, whatweb
```

---

## Phase 2 — Active Reconnaissance & Scanning

```
[ ] Host discovery:
    nmap -sn 10.10.10.0/24 --open -oG alive_hosts.txt

[ ] Full TCP port scan at the approved rate:
    SCAN_RATE=300
    nmap -p- --min-rate "$SCAN_RATE" --max-retries 2 -Pn -oA tcp_all "$TARGET"

[ ] Top ports with service detection:
    TOP_PORTS="22,80,443,445,3389,5985"
    nmap -sC -sV -p "$TOP_PORTS" -oA svc_scan "$TARGET"

[ ] UDP scan (top 20):
    sudo nmap -Pn -sU --top-ports 20 -oA udp_scan "$TARGET"

[ ] OS detection:
    sudo nmap -Pn -O "$TARGET"

[ ] NSE scripts for detected services:
    OPEN_PORTS="80,443,445"
    nmap -Pn --script vuln -p "$OPEN_PORTS" "$TARGET"
    nmap -Pn --script 'smb-vuln*' -p 445 "$TARGET"
    nmap -Pn --script 'http-* and not http-brute' -p 80,443,8080 "$TARGET"

[ ] Netcat banner grab key ports:
    for port in 21 22 25 110 143; do nc -nv -w 3 "$TARGET" "$port"; done
```

---

## Phase 3 — Service Enumeration

### Web (80/443/8080/8443)

```
[ ] whatweb, wappalyzer — tech stack
[ ] nikto — vulnerability scan
[ ] robots.txt, sitemap.xml, security.txt, .well-known/
[ ] HTTP methods: curl -X OPTIONS
[ ] Directory/file fuzzing: gobuster, ffuf, feroxbuster
    ffuf -u http://$TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -fc 404
[ ] Extension fuzzing: .php, .bak, .old, .conf, .sql, .git
[ ] Virtual host / subdomain fuzzing:
    ffuf -u http://$TARGET -H "Host: FUZZ.domain.com" -w subdomains.txt -fs <default_size>
[ ] Source code review: comments, API endpoints, JS files
[ ] JS file analysis: linkfinder, getJS
[ ] API endpoint discovery: swagger.json, api-docs, /api/v1/
[ ] Parameter discovery: paramspider, arjun
[ ] Check .git exposed: git-dumper, gittools
[ ] Check backup files: index.php.bak, config.php~
[ ] LFI/Path traversal test: ?file=../../etc/passwd
[ ] SQLi test: ?id=1'
[ ] XSS test: ?q=<script>alert(1)</script>
[ ] SSRF test: ?url=http://$LHOST:8080/
[ ] SSTI test: ?name={{7*7}}
```

### SMB (139/445)

```
[ ] nxc smb "$TARGET" — OS, signing, version
[ ] Null/anonymous session: smbclient -N -L //$TARGET
[ ] Guest access: nxc smb "$TARGET" -u guest -p ''
[ ] Shares enumeration: nxc smb "$TARGET" -u "$USER" -p "$PASS" --shares
[ ] File enumeration: manspider, smbclient
[ ] User enumeration: lookupsid, samrdump
[ ] Vuln check: nmap -Pn --script 'smb-vuln*' -p 445 "$TARGET"
[ ] EternalBlue check (MS17-010): nmap --script smb-vuln-ms17-010
[ ] PrintNightmare check: nmap -p 445 --script smb-vuln-ms10-061
```

### LDAP / Active Directory (389/636/88)

```
[ ] LDAP anonymous bind test
[ ] Domain user enumeration: kerbrute, lookupsid, ldapdomaindump
[ ] Password policy: net accounts /domain, Get-DomainDefaultPasswordPolicy
[ ] AS-REP Roasting (no creds): GetNPUsers.py
[ ] BloodHound collection (once creds obtained)
[ ] Kerberoasting: GetUserSPNs.py
[ ] ADCS enumeration: certipy find
```

### SSH (22)

```
[ ] Banner grab
[ ] Anonymous / default creds test
[ ] User enumeration via timing attack (old OpenSSH)
[ ] Check for key files: .ssh/authorized_keys, id_rsa
```

### FTP (21)

```
[ ] Anonymous login: ftp $TARGET / user: anonymous
[ ] List files, download all
[ ] Check write permissions
[ ] Look for credentials in uploaded files
```

### Other Services

```
[ ] DNS (53): zone transfer: dig @$TARGET domain.com AXFR
[ ] RDP (3389): test default/found creds, BlueKeep check
[ ] WinRM (5985): test default/found creds → evil-winrm
[ ] MSSQL (1433): netexec mssql, sa:sa, sa:, windows auth
[ ] MySQL (3306): mysql -u root -h $TARGET
[ ] SMTP (25): user enumeration (VRFY, EXPN), open relay test
[ ] SNMP (161/UDP): onesixtyone, snmpwalk, community strings
[ ] NFS (2049): showmount -e $TARGET, mount shares
[ ] Redis (6379): redis-cli -h $TARGET, KEYS *, config get dir
[ ] MongoDB (27017): mongo --host $TARGET, show dbs
[ ] Elasticsearch (9200): curl http://$TARGET:9200/_cat/indices
[ ] Memcached (11211): stats, dump keys
```

---

## Phase 4 — Vulnerability Analysis

```
[ ] Map services to known CVEs: searchsploit, vulnhub, NVD
[ ] Check versions: searchsploit "product version"
[ ] Check Metasploit: msfconsole search product
[ ] Run automated scanners: OpenVAS, Nuclei, nessus
    nuclei -u http://$TARGET -t /opt/nuclei-templates/
[ ] Check for default credentials on all services
[ ] Test authentication weaknesses: weak passwords, account lockout
[ ] Review discovered credentials against all services
```

---

## Phase 5 — Initial Exploitation

### Web Exploitation

```
[ ] Brute force login: hydra, medusa, burp intruder
[ ] SQL injection → data dump → credentials
[ ] File upload → webshell → RCE
[ ] Command injection (OS commands in web forms)
[ ] LFI → log poisoning / RCE
[ ] SSTI → RCE (Jinja2: {{config.__class__.__init__.__globals__['os'].popen('id').read()}})
[ ] Deserialization exploit (Java ysoserial, PHP unserialize)
[ ] XXE → SSRF → internal access / file read
[ ] SSRF → internal metadata / Redis / admin interfaces
[ ] Directory traversal → credential files
[ ] CVE exploits (Log4Shell, Spring4Shell, etc.)
```

### Network Exploitation

```
[ ] EternalBlue (MS17-010) → SYSTEM
[ ] BlueKeep (CVE-2019-0708) → RCE
[ ] PrintNightmare (CVE-2021-1675) → local SYSTEM / domain
[ ] ZeroLogon (CVE-2020-1472) → domain compromise
[ ] PetitPotam → NTLM relay → DCSync
[ ] NTLM relay: responder + ntlmrelayx
    Responder -I tun0 -w -d
    ntlmrelayx -tf targets.txt -smb2support -i
```

---

## Phase 6 — Post-Exploitation

### Linux

```
[ ] id, whoami, hostname, uname -a, ip a
[ ] sudo -l → NOPASSWD exploitation
[ ] SUID/GUID binaries → GTFOBins
[ ] Capabilities: getcap -r / 2>/dev/null
[ ] Cron jobs: cat /etc/crontab, pspy64
[ ] Writable files in root context
[ ] Credential hunting: history, configs, .env
[ ] SSH keys: id_rsa, authorized_keys
[ ] linpeas.sh automated scan
[ ] Docker socket / container escape
[ ] NFS no_root_squash
[ ] Kernel exploit research
```

### Windows

```
[ ] whoami /priv → SeImpersonatePrivilege (Potato)
[ ] whoami /groups → interesting group memberships
[ ] winPEAS.exe, Seatbelt.exe, PowerUp.ps1
[ ] Unquoted service paths
[ ] Writable service binaries
[ ] AlwaysInstallElevated registry check
[ ] Scheduled tasks with writable scripts
[ ] Credential hunting: findstr, registry, unattend.xml
[ ] LSASS dump: mimikatz, procdump
[ ] SAM/NTDS dump
[ ] Token impersonation: GodPotato, PrintSpoofer
[ ] DLL hijacking
[ ] UAC bypass
```

---

## Phase 7 — Lateral Movement

```
[ ] Map internal network from compromised host
[ ] Identify targets: ping sweep, port scan via proxychains/ligolo
[ ] Spray found credentials / hashes across network
[ ] nxc smb "$SUBNET" -u users.txt -p approved-password-candidates.txt --no-bruteforce
[ ] Pass-the-Hash: impacket-wmiexec, evil-winrm
[ ] Pass-the-Ticket: rubeus dump + inject
[ ] Set up pivot: chisel, ligolo-ng, ssh tunnel
[ ] Access identified services on internal hosts
[ ] Hunt for credentials on new hosts
[ ] Repeat PrivEsc on each new host
```

---

## Phase 8 — Active Directory Compromise

```
[ ] BloodHound — map all attack paths
[ ] Password spray domain users
[ ] AS-REP Roast → crack → reuse
[ ] Kerberoast → crack → service account access
[ ] ACL abuse: GenericAll, WriteDACL, WriteOwner
[ ] Shadow Credentials: pywhisker, certipy shadow
[ ] DCSync: secretsdump.py → all domain hashes
[ ] Golden Ticket: krbtgt hash → forge TGTs
[ ] ADCS vuln scan: certipy find -vulnerable
[ ] ESC1: request cert as DA
[ ] ESC8: NTLM relay to AD CS
[ ] Delegation abuse: unconstrained, constrained, RBCD
[ ] Trust attacks: child → parent domain
[ ] LAPS: read local admin passwords
[ ] GPO abuse: modify GPO if write rights
```

---

## Phase 9 — Persistence

```
[ ] Add backdoor admin user (local + domain)
[ ] SSH authorized_keys (Linux)
[ ] Registry autoruns (Windows)
[ ] Scheduled task (Windows)
[ ] Cron job (Linux)
[ ] Golden Ticket (AD — 10 year validity)
[ ] Silver Ticket (specific service)
[ ] AdminSDHolder backdoor ACL
[ ] Skeleton Key (DC — "mimikatz" password for all)
[ ] DSRM admin enabled
[ ] C2 agent: Cobalt Strike, Sliver, Havoc, Metasploit handler
```

---

## Phase 10 — Covering Tracks

> [!WARNING]
> Default closeout preserves customer logs and removes only exact artifacts created by the test team. Log clearing, timestamp manipulation, audit changes, and broad deletion require a separately approved detection objective and customer-led rollback verification.

```
[ ] Remove added users
[ ] Delete uploaded tools/shells from disk
[ ] Clear relevant Windows Event Logs:
    wevtutil cl System && wevtutil cl Security && wevtutil cl Application
[ ] Clear PowerShell history:
    Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
[ ] Linux log cleanup:
    > /var/log/auth.log
    > /var/log/syslog
    > ~/.bash_history && history -c
[ ] Remove cron jobs added
[ ] Remove persistence mechanisms
[ ] Revert modified registry keys
[ ] Revert modified ADCS templates
[ ] Remove added ACLs on AD objects
[ ] Stop/remove tunnels and listeners
[ ] Document everything removed for report
```

---

## Proof-of-Compromise Evidence

```
[ ] Screenshot: whoami + hostname + ip addr (Linux)
[ ] Screenshot: whoami /all + ipconfig /all (Windows)
[ ] Capture: local.txt / proof.txt contents + whoami
[ ] Screenshot: domain admin access if obtained
[ ] Save: all password hashes found
[ ] Document: full attack chain (how you got there)
```

---

## Report Checklist

```
[ ] Executive summary (non-technical)
[ ] Scope and methodology
[ ] Risk rating (Critical/High/Medium/Low/Info)
[ ] Each finding: Description + Evidence + Impact + Remediation
[ ] Attack chain narrative
[ ] Appendix: tool outputs, raw evidence
```

---

## One-Liner Setup (New Engagement)

```bash
export TARGET="10.10.10.X"
export LHOST="10.10.14.X"
export DOMAIN="corp.local"
export DC_IP="10.10.10.1"
export ENGAGEMENT_ID="customer-YYYYMMDD"
export SCAN_RATE="300"
umask 077
mkdir -p "$ENGAGEMENT_ID"/{notes,evidence,scans,artifacts,loot,report}
cd "$ENGAGEMENT_ID"
nmap -Pn -sC -sV -oA scans/initial "$TARGET"
nmap -Pn -p- --min-rate "$SCAN_RATE" --max-retries 2 -oA scans/allports "$TARGET"
```

---

## Related Notes

- [[01-Reconnaissance/Passive-OSINT]] — OSINT techniques
- [[01-Reconnaissance/Active-Reconnaissance]] — Active recon
- [[08-Active-Directory/INDEX]] — AD attack playbook
- [[06-Lateral-Movement/INDEX]] — Lateral movement
- [[05-Post-Exploitation/Linux-PrivEsc/INDEX]] — Linux PrivEsc
- [[05-Post-Exploitation/Windows-PrivEsc/INDEX]] — Windows PrivEsc
- [[07-Web-Application/SQLi]] — SQL injection
- [[07-Web-Application/XSS-SSRF-XXE-IDOR]] — Web attacks
- [[00-Quick-Reference/Reverse-Shells]] — Shell payloads
