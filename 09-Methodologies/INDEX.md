# Methodologies & Checklists

**Tags:** #methodology #checklist #pentest

## Core
- [[Full Checklist]] — Complete 10-phase pentest checklist (pre-engagement → report)

## Phase Playbooks
- [[01-Reconnaissance/INDEX]] — Recon phase
- [[06-Lateral-Movement/INDEX]] — Lateral movement
- [[08-Active-Directory/INDEX]] — AD attack chain
- [[05-Post-Exploitation/Linux-PrivEsc/INDEX]] — Linux PrivEsc
- [[05-Post-Exploitation/Windows-PrivEsc/INDEX]] — Windows PrivEsc

## Quick Setup
```bash
export TARGET="10.10.10.X"; export LHOST="10.10.14.X"
export DOMAIN="corp.local"; export DC_IP="10.10.10.1"
mkdir -p ~/engagements/$TARGET/{recon,scans,loot,exploits,screenshots}
sudo nmap -sC -sV -oA scans/initial $TARGET &
nmap -p- --min-rate 5000 -Pn -oA scans/allports $TARGET &
```