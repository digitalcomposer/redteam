---
tags: [enumeration, smb, samba, shares, rpc]
---

# SMB Enumeration

## Quick Fingerprint

```bash
nmap -sV -p 139,445 <target>
nmap --script smb-os-discovery,smb-security-mode,smb2-security-mode -p 445 <target>
netexec smb <target>
```

## Anonymous / Null Session

```bash
# List shares (null auth)
smbclient -L //<target> -N
smbmap -H <target>
netexec smb <target> -u '' -p '' --shares
netexec smb <target> -u 'guest' -p '' --shares

# Connect to share
smbclient //<target>/<share> -N
smbclient //<target>/<share> -U "<user>%<pass>"

# Recursive download
smbclient //<target>/<share> -N -c "prompt off; recurse on; mget *"
```

## Authenticated Enumeration

```bash
# Shares
netexec smb <target> -u <user> -p <pass> --shares
smbmap -H <target> -u <user> -p <pass> -R    # recursive listing

# Users
netexec smb <target> -u <user> -p <pass> --users
netexec smb <target> -u <user> -p <pass> --groups

# Password policy (for spray tuning)
netexec smb <target> -u <user> -p <pass> --pass-pol

# RID cycling (user enum without creds)
impacket-lookupsid <domain>/guest:@<target> -no-pass
netexec smb <target> -u '' -p '' --rid-brute 10000
```

## RPC Enumeration

```bash
rpcclient -U "" -N <target>
# RPC commands:
enumdomusers          # all domain users
enumdomgroups         # all domain groups
querydominfo          # domain info
getdompwinfo          # password policy
querydispinfo         # user details
enumprinters          # printers (for PrintNightmare check)
netshareenum          # shares
lsaenumsid            # SIDs

# One-liner dump
rpcclient -U "" -N <target> -c "enumdomusers" | grep -oP '\[.*?\]' | tr -d '[]'
```

## SMB Vulnerability Scanning

```bash
# EternalBlue (MS17-010)
nmap --script smb-vuln-ms17-010 -p 445 <target>
msfconsole -q -x "use auxiliary/scanner/smb/smb_ms17_010; set RHOSTS <target>; run"

# Full vuln scan
nmap --script "smb-vuln*" -p 445 <target>

# SMB signing (relay attack prerequisite)
nmap --script smb-security-mode -p 445 <target> | grep "message_signing"
netexec smb <subnet>/24 --gen-relay-list no_signing.txt
```

## Mount SMB Share

```bash
# Linux mount
sudo mount -t cifs //<target>/<share> /mnt/smb -o username=<user>,password=<pass>
sudo mount -t cifs //<target>/<share> /mnt/smb -o guest

# Unmount
sudo umount /mnt/smb
```

## Credential Spraying

```bash
netexec smb <target> -u users.txt -p <pass> --continue-on-success
netexec smb <target> -u <user> -p passwords.txt --continue-on-success
netexec smb <subnet>/24 -u <user> -p <pass> --continue-on-success
```

## Useful SMB Files to Hunt

```bash
# After mounting/connecting, look for:
*.txt, *.xml, *.conf, *.config, *.ini
web.config, appsettings.json, database.yml
id_rsa, *.pem, *.pfx, *.p12
```

## Related

- [[00-Quick-Reference/CrackMapExec]] — Full NetExec reference
- [[08-Active-Directory/INDEX]] — AD enumeration
- [[00-Quick-Reference/NTLM Theft]] — NTLM relay from SMB
