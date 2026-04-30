---
tags: [enumeration, ldap, active-directory, domain]
---

# LDAP Enumeration

## Anonymous Bind

```bash
# Check if anonymous bind allowed
ldapsearch -H ldap://<target> -x -b "" -s base namingcontexts

# Enumerate base DN
ldapsearch -H ldap://<target> -x -b "DC=domain,DC=com" "(objectClass=*)"

# Get all users (anonymous)
ldapsearch -H ldap://<target> -x -b "DC=domain,DC=com" "(objectClass=user)" sAMAccountName

# Get all computers
ldapsearch -H ldap://<target> -x -b "DC=domain,DC=com" "(objectClass=computer)" cn
```

## Authenticated Enumeration

```bash
# Full user dump
ldapsearch -H ldap://<dc-ip> -x -D "<user>@<domain>" -w <pass> \
  -b "DC=domain,DC=com" "(objectClass=user)" \
  sAMAccountName userPrincipalName memberOf description pwdLastSet

# All groups
ldapsearch -H ldap://<dc-ip> -x -D "<user>@<domain>" -w <pass> \
  -b "DC=domain,DC=com" "(objectClass=group)" cn member

# Domain Admins members
ldapsearch -H ldap://<dc-ip> -x -D "<user>@<domain>" -w <pass> \
  -b "DC=domain,DC=com" "(&(objectClass=user)(memberOf=CN=Domain Admins,CN=Users,DC=domain,DC=com))" sAMAccountName

# Accounts with no pre-auth (AS-REP roastable)
ldapsearch -H ldap://<dc-ip> -x -D "<user>@<domain>" -w <pass> \
  -b "DC=domain,DC=com" "(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))" sAMAccountName

# Kerberoastable (have SPN)
ldapsearch -H ldap://<dc-ip> -x -D "<user>@<domain>" -w <pass> \
  -b "DC=domain,DC=com" "(&(objectClass=user)(servicePrincipalName=*))" sAMAccountName servicePrincipalName
```

## windapsearch (Python)

```bash
# All users
python3 windapsearch.py -d <domain> -u <user>@<domain> -p <pass> --da
python3 windapsearch.py --dc-ip <dc-ip> -u <user>@<domain> -p <pass> -U

# Domain admins
python3 windapsearch.py --dc-ip <dc-ip> -u <user>@<domain> -p <pass> --da

# Privileged users
python3 windapsearch.py --dc-ip <dc-ip> -u <user>@<domain> -p <pass> --privileged-users

# Computers
python3 windapsearch.py --dc-ip <dc-ip> -u <user>@<domain> -p <pass> -C

# Custom filter
python3 windapsearch.py --dc-ip <dc-ip> -u <user>@<domain> -p <pass> \
  --custom "(servicePrincipalName=*)"
```

## ldapdomaindump

```bash
ldapdomaindump <dc-ip> -u '<domain>\<user>' -p '<pass>' --no-json --no-grep -o /tmp/ldap_dump/
# Output: domain_*.html files — easy to read in browser
```

## NetExec LDAP

```bash
netexec ldap <dc-ip> -u <user> -p <pass> --users
netexec ldap <dc-ip> -u <user> -p <pass> --groups
netexec ldap <dc-ip> -u <user> -p <pass> --password-not-required
netexec ldap <dc-ip> -u <user> -p <pass> --admin-count
netexec ldap <dc-ip> -u <user> -p <pass> --trusted-for-delegation
netexec ldap <dc-ip> -u <user> -p <pass> -M get-desc-users  # users with descriptions
```

## Useful LDAP Filters

```
# Disabled accounts
(userAccountControl:1.2.840.113556.1.4.803:=2)

# Never expires password
(userAccountControl:1.2.840.113556.1.4.803:=65536)

# Unconstrained delegation computers
(&(objectClass=computer)(userAccountControl:1.2.840.113556.1.4.803:=524288))

# Constrained delegation
(msDS-AllowedToDelegateTo=*)

# LAPS enabled computers
(ms-Mcs-AdmPwdExpirationTime=*)

# Computers with LAPS password readable
(ms-Mcs-AdmPwd=*)
```

## LDAPS (636)

```bash
# LDAP over SSL
ldapsearch -H ldaps://<target>:636 -x -b "DC=domain,DC=com" \
  "(objectClass=user)" -D "<user>@<domain>" -w <pass>

# Check cert
openssl s_client -connect <target>:636 -showcerts 2>/dev/null | openssl x509 -noout -text
```

## Related

- [[00-Quick-Reference/LDAP]] — Quick LDAP cheatsheet
- [[08-Active-Directory/INDEX]] — AD attack paths from enum data
- [[03-Enumeration/DNS-Enumeration]] — DNS enum
