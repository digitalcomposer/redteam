# Port Scanners Reference

**Tags:** #scanning #nmap #masscan #rustscan

---

## Nmap (Standard)

```bash
# Quick service scan
nmap -Pn -sV -sC -oA scans/quick "$TARGET"

# All ports + service detection
nmap -p- --min-rate "$SCAN_RATE" --max-retries 2 -Pn -oA scans/allports "$TARGET"

# Full deep scan on discovered open ports
nmap -Pn -sC -sV -p 22,80,443,8080 -oA scans/deep "$TARGET"

# UDP top 20
sudo nmap -Pn -sU --top-ports 20 -oA scans/udp "$TARGET"

# Aggressive (slow but comprehensive)
nmap -Pn -A -p- -T4 --min-rate "$SCAN_RATE" "$TARGET"

# Stealth SYN scan
sudo nmap -sS -p- --min-rate "$SCAN_RATE" -Pn "$TARGET"

# Vulnerability scripts
nmap -Pn --script vuln "$TARGET"
nmap -Pn --script "safe or default" "$TARGET"
```

## Masscan (High-Speed)

```bash
# All TCP ports at the approved rate
sudo masscan "$TARGET" -p1-65535 --rate "$SCAN_RATE" -oG scans/masscan.gnmap

# Specific ports across the approved subnet
sudo masscan "$SUBNET" -p22,80,443,445,3389,8080 --rate "$SCAN_RATE" -oG scans/masscan-services.gnmap

# Combine with nmap (masscan finds ports, nmap does service detection)
ports=$(awk '/Ports:/{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\/open\//){split($i,p,"/"); print p[1]}}' \
  scans/masscan.gnmap | sort -un | paste -sd, -)
test -n "$ports" && nmap -Pn -sV -sC -p "$ports" "$TARGET"
```

## RustScan (Fast + Nmap Integration)

```bash
# Quick scan then pipe to nmap
rustscan -a $TARGET -- -sV -sC
rustscan -a $TARGET -p 1-65535 -- -A

# Slower for stealth
rustscan -a $TARGET --ulimit 100 -- -sV -sC

# Batch/subnet
rustscan -a $SUBNET/24 -- -sV
```

## Netcat Port Scan (No Tools Available)

```bash
# TCP quick check
nc -zv $TARGET 22 80 443 445 3389

# Range
for port in $(seq 1 1024); do
  nc -zv -w 1 $TARGET $port 2>&1 | grep open
done

# PowerShell (Windows)
1..1024 | ForEach { $tcp = New-Object Net.Sockets.TcpClient
  $tcp.ConnectAsync("$TARGET", $_).Wait(100) | Out-Null
  if ($tcp.Connected) { Write-Host "OPEN: $_" } }
```

## Naabu (Go-based)

```bash
naabu -host $TARGET -p - -nmap-cli 'nmap -sV -sC'
naabu -list hosts.txt -p 80,443,8080,8443 -o open_ports.txt
```

## Output Management

```bash
# Parse nmap grepable output
grep open scan.gnmap | awk '{print $2}' > alive.txt
grep open scan.gnmap | grep -oP '\d+/open' | cut -d/ -f1 | sort -un > open_ports.txt

# Parse masscan output
grep open masscan.txt | awk '{print $4}' | cut -d/ -f1 | sort -un
```
