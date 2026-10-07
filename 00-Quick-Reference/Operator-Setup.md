# Operator Setup

## Engagement variables

Use one naming scheme throughout the vault:

```bash
export ENGAGEMENT_ID="customer-YYYYMMDD"
export TARGET="192.0.2.10"
export TARGET_URL="https://app.example.test"
export SUBNET="192.0.2.0/24"
export DOMAIN="example.test"
export DOMAIN_SHORT="EXAMPLE"
export DC_IP="192.0.2.11"
export LHOST="192.0.2.20"
export LPORT="4444"
export USER="authorized-test-user"
export INTERFACE="tun0"
export SCAN_RATE="300"
```

Do not export passwords, tokens, private keys, or reusable hashes. Read them interactively where supported:

```bash
read -rsp 'Password: ' PASSWORD; printf '\n'
# Use immediately, then clear it:
unset PASSWORD
```

## Workspace

```bash
umask 077
mkdir -p "$ENGAGEMENT_ID"/{notes,evidence,scans,loot,artifacts,report}
cd "$ENGAGEMENT_ID"
date -u +'%Y-%m-%dT%H:%M:%SZ' | tee engagement-start-utc.txt
```

Store the workspace on an encrypted volume. Keep customer material outside this repository.

## Command transcript

Linux:

```bash
script -q -f "evidence/terminal-$(date -u +%Y%m%dT%H%M%SZ).log"
```

PowerShell:

```powershell
Start-Transcript -Path ("evidence/transcript-{0}.txt" -f (Get-Date -Format 'yyyyMMddTHHmmssZ'))
```

Record the source host, source IP, target, operator, UTC time, tool version, exact command, result, and evidence filename for material actions.

## Target guard

Before active work, compare the resolved target with the signed allowlist:

```bash
getent ahostsv4 "$DOMAIN" | awk '{print $1}' | sort -u
printf 'Target=%s  Domain=%s  DC=%s  Source=%s\n' "$TARGET" "$DOMAIN" "$DC_IP" "$LHOST"
```

Stop when resolution returns an unapproved address, ownership is uncertain, or the emergency contact requests it.

## Tool provenance

Capture versions at engagement start:

```bash
{
  nmap --version | head -1
  nxc --version
  impacket-smbclient -h 2>&1 | head -1
  ffuf -V
  sqlmap --version
} | tee evidence/tool-versions.txt
```

For downloaded tools, record the source URL, release or commit, SHA-256 digest, and local filename before execution.
