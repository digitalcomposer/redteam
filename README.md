# RedTeam Playbooks

> Penetration testing knowledge base — kill-chain structured, copy-paste ready commands, Obsidian-native.

## What's Inside

251 markdown notes covering the full offensive security kill chain, from passive OSINT to Active Directory domain compromise, persistence, and covering tracks.

### Kill Chain Structure

| Phase | Directory | Coverage |
|-------|-----------|----------|
| 00 | `00-Quick-Reference/` | Service cheatsheets (SMB, LDAP, RDP, SNMP, gRPC, LFI, NetExec…) |
| 00 | `00-Reference/` | Payload references (SQLi, XSS, reverse shells, OPSEC, commands) |
| 01 | `01-Reconnaissance/` | Passive OSINT, active recon, service fingerprinting |
| 02 | `02-Scanning/` | Port scanning (nmap/masscan/rustscan), NSE scripts, service discovery |
| 03 | `03-Enumeration/` | SMB, LDAP, HTTP, DNS, MySQL, password cracking |
| 04 | `04-Exploitation/` | Exploitation index, BloodHound, Linux/Windows attack paths |
| 05 | `05-Exploitation/` | Linux, Windows, Network, Web exploitation playbooks |
| 05 | `05-Post-Exploitation/` | Linux PrivEsc, Windows PrivEsc (full playbooks) |
| 06 | `06-Post-Exploitation/` | Credential extraction, AD exploitation, PtH/PtT |
| 07 | `07-Web-Application/` | SQLi, XSS, SSRF, XXE, IDOR, file upload, SSTI |
| 08 | `08-Active-Directory/` | BloodHound, Kerberoast, AS-REP, DCSync, Golden/Silver tickets, ADCS ESC1/ESC4/ESC8, RBCD, ACL abuse |
| 08 | `08-Persistence/` | Linux/Windows/Web persistence techniques |
| 09 | `09-Covering-Tracks/` | Log removal, artifact cleanup, anti-forensics |
| 09 | `09-Methodologies/` | Full engagement checklist (10-phase) |

## Highlights

- **Active Directory**: Complete BloodHound Cypher queries, Kerberoasting, DCSync, Golden/Silver tickets, ADCS ESC1/ESC4/ESC8, shadow credentials, RBCD, delegation attacks, trust attacks
- **Lateral Movement**: WMI/WinRM/PSExec/DCOM, PtH/PtT/OPtH, Chisel/Ligolo-ng/SSH/Socat pivoting, full OPSEC comparison table
- **Linux PrivEsc**: sudo/SUID/capabilities/cron/PATH hijack/writable passwd/Docker escape/NFS/kernel exploits + checklist
- **Windows PrivEsc**: Potato attacks/service abuse/AlwaysInstallElevated/registry/DLL hijacking/UAC bypass
- **Web**: Union/error/blind SQLi + SQLMap, SSTI Jinja2/Twig/Freemarker RCE, XXE OOB, SSRF cloud metadata, LFI→RCE
- **OPSEC**: LOLBins, AMSI bypass, AV/EDR evasion, log awareness table, payload obfuscation

## Usage

### As an Obsidian Vault

```bash
git clone https://github.com/digitalcomposer/redteam.git
# Open the cloned folder in Obsidian as a vault
```

All notes use wikilinks (`[[Note-Name]]`) for navigation. The main vault index is at `INDEX.md`.

### As a Standalone Reference

Each note is self-contained with commands ready to copy-paste. Set your environment variables once:

```bash
export TARGET=<target-ip>
export LHOST=<your-ip>
export LPORT=4444
export DOMAIN=<domain.com>
export DC_IP=<dc-ip>
export USER=<username>
export PASS=<password>
```

Then commands using `$TARGET`, `$LHOST`, etc. work directly.

## Structure Details

```
redteam/
├── INDEX.md                          # Vault navigation hub
├── 00-Quick-Reference/               # 30+ service quick-refs
│   ├── CrackMapExec.md              # Full NetExec reference
│   ├── Evil-WinRM.md
│   ├── Reverse-Shells.md
│   ├── LDAP.md / LDAPSearch.md
│   ├── NTLM Theft.md
│   ├── SSH Tunneling.md
│   └── ...
├── 08-Active-Directory/
│   └── INDEX.md                     # Complete AD attack playbook
├── 06-Lateral-Movement/
│   └── INDEX.md                     # Pivoting + PtH playbook
├── 05-Post-Exploitation/
│   ├── Linux-PrivEsc/INDEX.md       # Full Linux PrivEsc
│   └── Windows-PrivEsc/INDEX.md     # Full Windows PrivEsc
├── 07-Web-Application/
│   ├── SQLi.md
│   └── XSS-SSRF-XXE-IDOR.md
└── 09-Methodologies/
    └── Full Checklist.md            # 10-phase engagement checklist
```

## Disclaimer

This repository is intended for **authorized penetration testing, CTF competitions, and security research only**. Always obtain written permission before testing any system you do not own. The authors are not responsible for misuse.

---

*Maintained with [Claude Code](https://claude.ai/code)*
