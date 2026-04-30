# Port Scanners Reference

**Tags:** #scanning #nmap #masscan #rustscan

---

## Nmap (Standard)

```bash
# Quick service scan
nmap -sV -sC -oA quick $TARGET

# All ports + service detection
nmap -p- --min-rate 5000 -Pn -oA allports $TARGET

# Full deep scan on discovered open ports
nmap -sC -sV -p 80,443,8080,22 -oA deep $TARGET

# UDP top 20
nmap -sU --top-ports 20 -oA udp $TARGET

# Aggressive (slow but comprehensive)
nmap -A -p- -T4 $TARGET

# Stealth SYN scan
nmap -sS -p- --min-rate 5000 -Pn $TARGET

# Vulnerability scripts
nmap --script vuln $TARGET
nmap --script "safe or default" $TARGET
```

## Masscan (High-Speed)

```bash
# All ports — extremely fast
masscan $TARGET -p0-65535 --rate 10000 -oG masscan.txt

# Specific ports at max speed
masscan $SUBNET/24 -p 22,80,443,445,3389,8080 --rate 100000

# Combine with nmap (masscan finds ports, nmap does service detection)
masscan $TARGET -p0-65535 --rate 10000 | grep open | awk '{print $4}' | cut -d/ -f1 | tr '\n' ',' | xargs -I{} nmap -sV -p {} $TARGET
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
