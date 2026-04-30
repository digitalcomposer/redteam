# MySQL Enumeration (Port 3306)

**Source:** gabb4r/OSCP Notes Integration

## Nmap Enumeration

```bash
nmap -sV -Pn -vv --script=mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info $ip -p 3306

nmap -sV -Pn -vv --script=mysql* $ip -p 3306
```

## Local Access

If shell access to target system with MySQL running:

```bash
mysql -u root                    # Connect as root (no password)
mysql -u root -p                # Connect as root (with password prompt)
mysql -u root --default-character-set=utf8
```

Always test root:root credentials.

## Remote Access

```bash
mysql -h <Hostname> -u root
mysql -h <Hostname> -u root@localhost
mysql -h <IP> -u admin -p
```

## Executing Commands (If Running as Root)

```sql
SELECT sys_exec("id");
SELECT sys_eval("whoami");
```

## Extracting Database Information

```sql
SHOW DATABASES;
USE database_name;
SHOW TABLES;
DESC table_name;
SELECT * FROM users;
```

## Post-Exploitation Enumeration

Files to check for credentials/sensitive info after shell access:

### MySQL Configuration Files
- **Unix**: `/etc/mysql/mysql.conf.d/mysqld.cnf`, `~/.my.cnf`
- **Windows**: `C:\ProgramData\MySQL\MySQL Server 5.7\my.ini`

### Command History
```bash
cat ~/.mysql_history
```

### Log Files
```
/var/log/mysql/error.log
/var/log/mysql/mysql.log
```

### Finding MySQL Passwords

When you gain shell access and need privilege escalation:
1. Look into databases for user credentials
2. Check configuration files for password references
3. Review application databases for stored credentials

## Related Notes

- [[03-Enumeration/Oracle-Enumeration]] → Database enumeration
- [[03-Enumeration/MsSQL-Enumeration]] → Windows database
- [[05-Post-Exploitation]] → Post-shell enumeration
