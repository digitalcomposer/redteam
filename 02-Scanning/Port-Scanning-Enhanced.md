# Nmap Port Scanning

## Scan for Alive Hosts
```bash
nmap -sn $ip/24
nmap -vvv -sn $ip/24
nmap -sn -n $ip/24 > ip-range.txt  # Faster option
```

## Scan Specific IP Range
```bash
nmap -sP 10.0.0.0-100
```

## Auto Recon
```bash
autorecon 10.10.10.3
```

## Initial Scan TCP
```bash
nmap -sC -sV -O -oA initial 10.10.10.3
```

## Full Scan TCP
Comprehensive nmap scans in background. Covers all 65535 ports.

## Full Scan UDP
UDP scan for all ports.

## Normal Scan
Standard TCP port scan with common options.

## Scan Common Ports (1024 Most Common)
```bash
# Scans 1024 most common ports
# Runs OS detection
# Runs default nmap scripts
# Saves to .nmap, .gnmap, .xml
# Faster than full scan
nmap -sC -sV -O --top-ports 1024 -oA scan $ip
```

## Fast Scanning
Scan 100 most common ports for quick assessment.

## Quick TCP Scan
Fast TCP port discovery on common ports.

## Quick UDP Scan
Fast UDP port discovery on common ports.

## Full TCP Scan
Complete TCP port enumeration (65535 ports). **Note**: Takes long time. Recommended to run overnight.

## Port Knock
Port knock enumeration for hidden services.

## Deep Scanning
```bash
# Scan all 65535 ports with full connect scan
# Very long runtime (days possible)
# Print results immediately instead of waiting
nmap -sT -p- -v $ip
```
**Tip**: For overnight scanning, leave running and continue with other targets.

## Maximum Scan Delay
Use `--max-scan-delay` to specify maximum time between probes.

## Maximum Retries
Use `--max-retries` to control packet resend attempts per port.
- Set to 0 = send once, no retries
- Default = 2 retries per port

## Scan for Specific Port
```bash
nmap -p T:$port $ip  # TCP port
nmap -p U:$port $ip  # UDP port
```

## Scan Unused IP Addresses
Identify available IPs and store results.

## UDP Scanning
UDP scans are slower and less reliable than TCP. Use for service enumeration only.

## Top Ports
```bash
# Scan top 20 ports with OS detection and scripts
nmap -A --top-ports 20 $ip
```

## Scan Targets from File
```bash
nmap -iL targets.txt
```

## OnetwoPunch.sh
Script that uses unicornscan for full port sweep, then passes open ports to nmap for service detection. Provides comprehensive enumeration in single workflow.

## AutoRecon
Multi-threaded automated network reconnaissance tool. GitHub: Tib3rius/AutoRecon

---

**Source**: gabb4r/OSCP notes integration
**Last Updated**: 2026-04-28
