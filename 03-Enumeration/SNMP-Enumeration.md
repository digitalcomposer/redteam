# SNMP Enumeration (Port 161)

## Quick Intro
Simple Network Management Protocol operates on UDP 161. Used to collect/manage networked device information.

### SNMP Components
1. **Managed Device (Node)**: Network device with SNMP enabled
2. **Agent**: Software on device handling communication
3. **Network Management System (NMS)**: Manages/monitors devices

### SNMP Commands
- **Read**: Monitor nodes
- **Write**: Control nodes
- **Trap**: Unsolicited messages from agent to NMS
- **Traversal**: Check retained information on device

### SNMP Management Information Base (MIB)
Database of device information. Values indexed by dot notation (e.g., 1.3.6.1.2.1.1.1 = sysDescr).

### SNMP Community Strings
Like usernames/passwords for device access:
- **public**: Default read-only (SMBv1/v2)
- **private**: Default read-write (SMBv1/v2)
- **Traps**: SNMP trap configuration

### Common MIB Trees
```
1.3.6.1.2.1.25.1.6.0          System Processes
1.3.6.1.2.1.25.4.2.1.2        Running Programs
1.3.6.1.2.1.25.4.2.1.4        Processes Path
1.3.6.1.2.1.25.2.3.1.4        Storage Units
1.3.6.1.2.1.25.6.3.1.2        Software Name
1.3.6.1.4.1.77.1.2.25         User Accounts
1.3.6.1.2.1.6.13.1.3          TCP Local Ports
```

## SNMPwalk
Query MIB values to retrieve device information. Requires valid SNMP read-only community string.

## SNMPcheck
Similar to snmpwalk with nicer output formatting.

## Brute Force Community Strings

### OneSixtyOne
Very fast SNMP community string brute force tool. Exploits connectionless protocol:
- Sends SNMP request
- Waits 10ms for response
- Invalid string = dropped
- Valid string = device responds with requested data

## Wordlists
Precompiled lists for community string brute force.

## NSE Script
Nmap scripts for SNMP enumeration and vulnerability scanning.

## SNMPv3 Enumeration
Newer SNMP version with username/password authentication instead of community strings.

---

**Source**: gabb4r/OSCP notes integration  
**Last Updated**: 2026-04-28
