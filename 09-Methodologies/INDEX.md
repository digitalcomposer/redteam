# Methodologies & Checklists

**Tags:** #methodology #checklist #pentest

## Core
- [[Engagement-Workflow]] — Approval gates, evidence handling, deconfliction, rollback, and reporting
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
export ENGAGEMENT_ID="customer-YYYYMMDD"
mkdir -p "$ENGAGEMENT_ID"/{notes,evidence,scans,artifacts,report}
cd "$ENGAGEMENT_ID"
# Run only after scope and scan-rate approval:
sudo nmap -sC -sV -oA scans/initial "$TARGET"
nmap -p- --min-rate 300 -Pn -oA scans/allports "$TARGET"
```
