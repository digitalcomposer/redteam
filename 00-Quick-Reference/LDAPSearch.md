---
tags: [reference, ldap, ldapsearch, active-directory]
---

# LDAPSearch Quick Reference

> Full LDAP enum guide: [[03-Enumeration/LDAP-Enumeration]]

## Basic Syntax

```bash
ldapsearch -H ldap://<target> -x -b "<base-dn>" "<filter>" [attributes]

# Options:
# -H  LDAP URI
# -x  simple authentication (not SASL)
# -D  bind DN (username)
# -w  password
# -b  search base
# -s  scope: base, one, sub (default: sub)
# -LLL  suppress extra output
```

## Anonymous Enumeration

```bash
# Get naming contexts (find base DN)
ldapsearch -H ldap://<target> -x -b "" -s base namingcontexts

# Enumerate root DSE
ldapsearch -H ldap://<target> -x -b "" -s base "(objectClass=*)"

# All objects (anonymous — usually restricted)
ldapsearch -H ldap://<target> -x -b "DC=domain,DC=com" "(objectClass=*)"
```

## Authenticated Queries

```bash
# Users
ldapsearch -H ldap://<dc-ip> -x \
  -D "user@domain.com" -w "password" \
  -b "DC=domain,DC=com" \
  "(objectClass=user)" sAMAccountName memberOf

# All computers
ldapsearch -H ldap://<dc-ip> -x \
  -D "user@domain.com" -w "password" \
  -b "DC=domain,DC=com" \
  "(objectClass=computer)" cn operatingSystem

# All groups
ldapsearch -H ldap://<dc-ip> -x \
  -D "user@domain.com" -w "password" \
  -b "DC=domain,DC=com" \
  "(objectClass=group)" cn member

# Domain Admins
ldapsearch -H ldap://<dc-ip> -x \
  -D "user@domain.com" -w "password" \
  -b "DC=domain,DC=com" \
  "(&(objectClass=user)(memberOf=CN=Domain Admins,CN=Users,DC=domain,DC=com))" \
  sAMAccountName
```

## Useful Filters

```bash
# Accounts with SPN (Kerberoastable)
"(&(objectClass=user)(servicePrincipalName=*))"

# No pre-auth (AS-REP roastable)
"(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))"

# Unconstrained delegation (computers)
"(&(objectClass=computer)(userAccountControl:1.2.840.113556.1.4.803:=524288))"

# Constrained delegation
"(msDS-AllowedToDelegateTo=*)"

# LAPS passwords readable
"(ms-Mcs-AdmPwd=*)"

# Disabled accounts
"(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2))"

# Password never expires
"(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))"

# Accounts with descriptions (often have passwords)
"(&(objectClass=user)(description=*))"

# Admin count = 1 (was in privileged group)
"(&(objectClass=user)(adminCount=1))"
```

## Password Search in Descriptions

```bash
ldapsearch -H ldap://<dc-ip> -x \
  -D "user@domain.com" -w "password" \
  -b "DC=domain,DC=com" \
  "(&(objectClass=user)(description=*))" \
  sAMAccountName description | grep -A1 "description:"
```

## ldapdomaindump (HTML Output)

```bash
ldapdomaindump <dc-ip> -u 'domain\user' -p 'password' -o /tmp/ldap/
# Open /tmp/ldap/domain_users.html in browser
```

## NetExec LDAP Module

```bash
netexec ldap <dc-ip> -u user -p pass --users
netexec ldap <dc-ip> -u user -p pass --groups
netexec ldap <dc-ip> -u user -p pass --password-not-required
netexec ldap <dc-ip> -u user -p pass --trusted-for-delegation
netexec ldap <dc-ip> -u user -p pass --admin-count
netexec ldap <dc-ip> -u user -p pass -M get-desc-users
netexec ldap <dc-ip> -u user -p pass -M laps    # Read LAPS passwords
```

## Related

- [[03-Enumeration/LDAP-Enumeration]] — Full LDAP enumeration guide
- [[00-Quick-Reference/LDAP]] — LDAP quick reference
- [[08-Active-Directory/INDEX]] — AD attacks
