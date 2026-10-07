# Penetration Testing Vault

**Professional operator reference.**
Engagement flow: [[09-Methodologies/Engagement-Workflow]] → reconnaissance → validation → reporting → controlled cleanup.

---

## Kill Chain (9 Phases)

| Phase | Section | Focus |
|-------|---------|-------|
| 1 | [[01-Reconnaissance/Passive-OSINT]] | OSINT, target profiling, subdomains |
| 1 | [[01-Reconnaissance/Active-Reconnaissance]] | Port scanning, service enumeration |
| 2 | [[02-Scanning/INDEX]] | Port scanning and service discovery |
| 3 | [[03-Vulnerability-Analysis/Gabb4r-Reference]] | CVE lookup, exploit research |
| 4 | [[04-Exploitation/Linux/Linux]] | Linux initial access |
| 4 | [[04-Exploitation/Windows/Windows]] | Windows initial access |
| 5 | [[05-Post-Exploitation/Linux-PrivEsc/INDEX]] | Linux privilege escalation |
| 5 | [[05-Post-Exploitation/Windows-PrivEsc/INDEX]] | Windows privilege escalation |
| 6 | [[06-Lateral-Movement/INDEX]] | Pivoting, PtH, PtT, tunneling |
| 7 | [[07-Web-Application/Web-Scanning]] | Web enumeration |
| 7 | [[07-Web-Application/SQLi]] | SQL injection |
| 7 | [[07-Web-Application/XSS-SSRF-XXE-IDOR]] | XSS, SSRF, XXE, IDOR |
| 7 | [[07-Web-Application/File-Upload]] | File upload exploitation |
| 8 | [[08-Active-Directory/INDEX]] | Full AD attack playbook |
| 9 | [[09-Covering-Tracks/INDEX]] | Authorized restoration and artifact cleanup |
| 10 | [[10-Reporting/INDEX]] | Findings, evidence, closeout, and retest |

---

## Methodology

[[09-Methodologies/Full Checklist]] — Ultimate pentest checklist (phases 0–10)

[[09-Methodologies/Engagement-Workflow]] — Approval gates, evidence discipline, deconfliction, cleanup, and reporting

[[00-Quick-Reference/Operator-Setup]] — Standard variables, workspace, transcripts, and tool provenance

---

## Quick Reference

[[00-Quick-Reference/Reverse-Shells]] | [[00-Quick-Reference/NMAP]] | [[00-Quick-Reference/Mimikatz]]
[[00-Quick-Reference/Kerberoasting]] | [[00-Quick-Reference/Password Cracking]] | [[00-Quick-Reference/OPSEC]]
[[00-Quick-Reference/Pivoting]] | [[00-Quick-Reference/Tunneling]] | [[00-Quick-Reference/SMB]]
[[00-Quick-Reference/Active Directory Certification Services]] | [[00-Quick-Reference/NTLM Theft]]
[[00-Quick-Reference/SQLMap]] | [[00-Quick-Reference/LFI]] | [[00-Quick-Reference/SSTI Payloads]]
[[00-Quick-Reference/Evil-WinRM]] | [[00-Quick-Reference/CrackMapExec]] | [[00-Quick-Reference/Impacket]]

---

## Cheat Sheets

| Tool/Attack | Note |
|-------------|------|
| Nmap scanning | [[00-Quick-Reference/NMAP]] |
| Kerberoasting / AS-REP | [[00-Quick-Reference/Kerberoasting]] |
| Credential dumping | [[00-Quick-Reference/Mimikatz]] |
| Password cracking | [[00-Quick-Reference/Password Cracking]] |
| AD CS attacks | [[00-Quick-Reference/Active Directory Certification Services]] |
| SMB enumeration | [[00-Quick-Reference/SMB]] |
| LDAP | [[00-Quick-Reference/LDAPSearch]] |
| Pivoting & tunneling | [[00-Quick-Reference/Pivoting]] + [[00-Quick-Reference/Tunneling]] |
| OPSEC considerations | [[00-Quick-Reference/OPSEC]] |
| Reverse shells | [[00-Quick-Reference/Reverse-Shells]] |

---

Updated: 2026-04-30
