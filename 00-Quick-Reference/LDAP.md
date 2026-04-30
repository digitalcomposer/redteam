# LDAP Enumeration

**Tags:** #ldap #enumeration #active-directory
**Ports:** 389 (LDAP), 636 (LDAPS), 3268 (GC), 3269 (GC+SSL)

---

## Unauthenticated / Null Bind

```bash
# Test anonymous bind
ldapsearch -x -H ldap://$DC_IP -b '' -s base '(objectclass=*)' namingContexts
ldapsearch -x -H ldap://$DC_IP -b "DC=corp,DC=local"

# Nmap check
nmap -p 389 --script ldap-rootdse $DC_IP
nmap -p 389 --script ldap-search --script-args 'ldap.base="dc=corp,dc=local"' $DC_IP
```

## Authenticated Enumeration

```bash
# Full domain dump
ldapdomaindump $DC_IP -u "DOMAIN\\$USER" -p "$PASS" -o ldap_dump/

# All users
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "DC=corp,DC=local" "(objectClass=person)" sAMAccountName description memberOf

# All groups
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "DC=corp,DC=local" "(objectClass=group)" cn member

# All computers
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "DC=corp,DC=local" "(objectClass=computer)" cn operatingSystem

# SPNs (Kerberoastable)
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "DC=corp,DC=local" "(&(objectClass=user)(servicePrincipalName=*))" sAMAccountName servicePrincipalName

# AS-REP Roastable (pre-auth disabled)
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "DC=corp,DC=local" "(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))" sAMAccountName

# Admins only
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "CN=Domain Admins,CN=Users,DC=corp,DC=local" member

# Password policy
ldapsearch -x -H ldap://$DC_IP -D "CN=$USER,CN=Users,DC=corp,DC=local" -w $PASS \
  -b "DC=corp,DC=local" "(objectClass=domain)" lockoutThreshold minPwdLength maxPwdAge
```

## With Hash (Pass-the-Hash via Kerberos)

```bash
ldapdomaindump $DC_IP -u "$DOMAIN\\$USER" --hashes :NTLMHASH -o ldap_dump/
```

## Useful Filters

```bash
# Find disabled accounts
"(userAccountControl:1.2.840.113556.1.4.803:=2)"

# Find accounts never expiring
"(userAccountControl:1.2.840.113556.1.4.803:=65536)"

# Find users with description field containing "pass"
"(&(objectClass=user)(description=*pass*))"

# Find computers with unconstrained delegation
"(&(objectClass=computer)(userAccountControl:1.2.840.113556.1.4.803:=524288))"

# Find accounts with admin count
"(&(objectClass=user)(adminCount=1))"
```

## windapsearch

```bash
# Go-based windapsearch
./windapsearch -d $DOMAIN --dc $DC_IP -u $USER -p $PASS --da  # Domain admins
./windapsearch -d $DOMAIN --dc $DC_IP -u $USER -p $PASS -U    # All users
./windapsearch -d $DOMAIN --dc $DC_IP -u $USER -p $PASS -G    # All groups
./windapsearch -d $DOMAIN --dc $DC_IP -u $USER -p $PASS --computers
./windapsearch -d $DOMAIN --dc $DC_IP -u $USER -p $PASS --spns  # Kerberoastable
./windapsearch -d $DOMAIN --dc $DC_IP -u $USER -p $PASS --unconstrained-users
```

## Related Notes

- [[08-Active-Directory/INDEX]] — Full AD attack playbook
- [[00-Quick-Reference/LDAPSearch]] — Quick ldapsearch reference
- [[00-Quick-Reference/Kerberoasting]] — Abuse discovered SPNs
