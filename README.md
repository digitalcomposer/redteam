# RedTeam Playbooks

An operator-focused knowledge base for authorized penetration testing, adversary simulation, security labs, and technical research.

The repository organizes 139 Markdown files around the practical lifecycle of an engagement: authorization, reconnaissance, scanning, service enumeration, vulnerability analysis, exploitation, privilege escalation, Active Directory operations, lateral movement, persistence, web application testing, evidence handling, cleanup, reporting, and retesting.

It is designed to work both as an [Obsidian](https://obsidian.md/) vault and as a standalone command reference.

> [!CAUTION]
> Use these playbooks only against systems covered by explicit written authorization. Confirm the exact scope, source addresses, test window, rate limits, prohibited techniques, data-handling requirements, abort conditions, and rollback responsibilities before sending traffic. High-impact actions require the approval defined in the Rules of Engagement.

## Repository goals

- Put the full offensive workflow in one navigable vault.
- Keep commands close to their prerequisites, expected effect, evidence needs, and cleanup steps.
- Cover manual validation as well as common offensive tooling.
- Preserve technically useful exploitation, credential access, persistence, lateral movement, and evasion material.
- Support professional evidence handling, reporting, retesting, and customer closeout.
- Reduce command drift through canonical references and automated link and content checks.

This is a field reference, not an automated attack framework. Commands remain environment-dependent: confirm tool versions, target architecture, protocol behavior, and operational impact before execution.

## Coverage

| Area | Included material |
|---|---|
| Engagement control | Rules of Engagement, scope validation, source IPs, stop conditions, rate limits, deconfliction, data handling |
| Reconnaissance | Passive OSINT, DNS, certificate transparency, target profiling, active discovery |
| Scanning | Nmap, Masscan, RustScan, Naabu, NSE selection, TCP and UDP workflows, service discovery |
| Enumeration | SMB, LDAP, HTTP, DNS, FTP, SSH, SMTP, POP3, SNMP, NFS, MySQL, MSSQL, Oracle, gRPC |
| Vulnerability analysis | Version validation, CVE research, SearchSploit, exploit review, PoC adaptation |
| Windows and AD | BloodHound, Kerberos attacks, AD CS, ACL abuse, delegation, RBCD, DCSync, credential and ticket operations |
| Linux | Enumeration, SUID, sudo, capabilities, cron, PATH, services, containers, NFS, kernel exploitation |
| Lateral movement | WMI, WinRM, PsExec, SMBExec, DCOM, PtH, PtT, Overpass-the-Hash, SSH, Chisel, Ligolo-ng, Socat |
| Web applications | SQLi, XSS, SSTI, SSRF, XXE, IDOR, LFI, file upload, CMS enumeration, directory fuzzing |
| Persistence and evasion | Linux, Windows, web and domain persistence; telemetry-aware OPSEC and controlled detection exercises |
| Reporting | Evidence and artifact registers, finding structure, severity inputs, remediation, cleanup, retesting |

## Start here

| Resource | Purpose |
|---|---|
| [Vault index](INDEX.md) | Primary navigation across all phases |
| [Operator setup](00-Quick-Reference/Operator-Setup.md) | Variables, secure workspace, transcripts, target checks, and tool provenance |
| [Engagement workflow](09-Methodologies/Engagement-Workflow.md) | Authorization gates, validation discipline, evidence, cleanup, and closeout |
| [Full checklist](09-Methodologies/Full%20Checklist.md) | End-to-end operational checklist |
| [Rules of Engagement template](templates/Rules-of-Engagement.md) | Scope, permissions, operating limits, safety, and communications |
| [Finding template](templates/Finding.md) | Reproduction, evidence, impact, root cause, remediation, and retest |
| [Evidence register](templates/Evidence-Register.md) | Evidence identifiers, hashes, provenance, classification, and retention |
| [Artifact register](templates/Artifact-Register.md) | Created objects, modified state, rollback owner, and verification |
| [Reporting and closeout](10-Reporting/INDEX.md) | Finding lifecycle, deliverables, quality gate, and retesting |

## Engagement lifecycle

| Phase | Directory | Focus |
|---:|---|---|
| 00 | [`00-Quick-Reference/`](00-Quick-Reference/) | Operator setup, tools, protocols, payloads, and fast lookup |
| 00 | [`00-Reference/`](00-Reference/) | Extended command, OPSEC, SQLi, XSS, and reverse-shell references |
| 01 | [`01-Reconnaissance/`](01-Reconnaissance/) | Passive and active reconnaissance |
| 02 | [`02-Scanning/`](02-Scanning/) | Port discovery, scan profiles, NSE, and service identification |
| 03 | [`03-Enumeration/`](03-Enumeration/) | Protocol-specific enumeration and credential testing |
| 04 | [`04-Vulnerability-Analysis/`](04-Vulnerability-Analysis/) | CVE research and exploit selection |
| 05 | [`05-Exploitation/`](05-Exploitation/) | Linux, Windows, network, and web exploitation |
| 05–06 | [`05-Post-Exploitation/`](05-Post-Exploitation/) and [`06-Post-Exploitation/`](06-Post-Exploitation/) | Privilege escalation, credential access, and situational awareness |
| 06–07 | [`06-Lateral-Movement/`](06-Lateral-Movement/) and [`07-Lateral-Movement/`](07-Lateral-Movement/) | Remote execution, credential reuse, tunneling, and pivoting |
| 07 | [`07-Web-Application/`](07-Web-Application/) | Web discovery and exploitation techniques |
| 08 | [`08-Active-Directory/`](08-Active-Directory/) | Domain attack paths and AD-specific operations |
| 08 | [`08-Persistence/`](08-Persistence/) | Linux, Windows, web, and domain persistence |
| 09 | [`09-Covering-Tracks/`](09-Covering-Tracks/) | Controlled cleanup and authorized detection-evasion exercises |
| 09 | [`09-Methodologies/`](09-Methodologies/) | Engagement workflow and checklists |
| 10 | [`10-Reporting/`](10-Reporting/) | Reporting, closeout, and retesting |

## Installation

```bash
git clone https://github.com/digitalcomposer/redteam.git
cd redteam
```

Open the repository root as an Obsidian vault, or browse the Markdown files directly in GitHub or any editor. Internal notes use Obsidian wikilinks, while this README uses standard Markdown links for GitHub navigation.

## Operator setup

Use documentation-safe example addresses and keep secrets out of the repository and shell history:

```bash
export ENGAGEMENT_ID="customer-YYYYMMDD"
export TARGET="192.0.2.10"
export TARGET_URL="https://app.example.test"
export SUBNET="192.0.2.0/24"
export DOMAIN="example.test"
export DC_IP="192.0.2.11"
export LHOST="192.0.2.20"
export LPORT="4444"
export USER="authorized-test-user"
export INTERFACE="tun0"
export SCAN_RATE="300"

umask 077
mkdir -p "$ENGAGEMENT_ID"/{notes,evidence,scans,loot,artifacts,report}
cd "$ENGAGEMENT_ID"
```

Passwords, tokens, reusable hashes, tickets, private keys, customer data, and collected graph data belong in the approved engagement storage. Use interactive prompts or an approved secret manager.

## Recommended operating model

1. Complete the Rules of Engagement and verify every target against the approved scope.
2. Create an encrypted engagement workspace outside this repository.
3. Capture tool versions, operator identity, source address, and UTC start time.
4. Begin with the lowest-impact discovery method and the approved scan rate.
5. Validate findings with the smallest proof that demonstrates impact.
6. Record evidence, hashes, timestamps, affected assets, and created artifacts as work progresses.
7. Remove exact operator-created artifacts and restore captured before-state values.
8. Deliver findings, attack paths, cleanup status, limitations, and retest criteria.

## Command conventions

- `$TARGET`, `$SUBNET`, `$DOMAIN`, `$DC_IP`, `$LHOST`, and `$USER` refer to approved engagement values.
- Values written as `<placeholder>` must be replaced before execution; angle brackets are not valid literal shell arguments.
- `nxc` is the preferred NetExec command. Older notes or external material may still call it `netexec` or CrackMapExec.
- Commands using `sudo`, remote execution, credential access, endpoint-protection changes, persistence, log modification, or production writes have material operational impact.
- Downloaded scripts and binaries should be pinned where possible, hashed, reviewed, and recorded before execution.
- Scan speed is a deployment decision. Start with the approved baseline and increase it only after checking packet loss and target stability.

## Quality controls

The repository includes a local quality gate and a GitHub Actions workflow. The checker validates:

- Obsidian wikilink targets;
- balanced fenced code blocks;
- private-key markers;
- direct `curl | shell` and `wget | shell` execution patterns.

Run it locally with:

```bash
ruby scripts/check-vault.rb
```

Content and command contribution requirements are documented in [CONTRIBUTING.md](CONTRIBUTING.md).

## Responsible use

This repository contains offensive security procedures capable of changing systems, obtaining credentials, executing code, establishing persistence, moving laterally, and affecting telemetry. Those capabilities are included for legitimate professional testing, controlled adversary simulation, labs, and research.

Possession of a technique does not establish authorization to use it. The operator remains responsible for confirming scope, legal authority, customer approval, target ownership, operational safety, evidence handling, and restoration requirements.

## License

See [LICENSE](LICENSE).
