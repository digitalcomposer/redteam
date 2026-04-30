# NFS Enumeration (Port 111, 2049)

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- Developed in 1984 by Sun Microsystem, similar to SMB
- Allows access to files over a network
- Common ports: 111 (RPC) and 2049 (NFS) TCP/UDP
- Client/server system for remote file access

## Identifying NFS in Use

```bash
rpcinfo -p <ip>
# If 111 and 2049 listed, shares are enabled
```

## Show All Mounts

```bash
showmount -e $ip
```

## Mount NFS Share

```bash
mkdir /mnt/nfs
mount -t nfs <ip>:<remote_path> /mnt/nfs
```

## Unmount NFS Share

```bash
umount /mnt/nfs
```

## Permission Denied Issues

If encountering permission denied, try:
- Mount with `nosuid,nodev,noexec` options
- Check `/etc/exports` on target for access restrictions
- Exploit: Write SSH keys if share is writable

## Further Exploitation

If write access available:
1. Copy SSH public key to `~/.ssh/authorized_keys`
2. Gain passwordless SSH access to target

## Nmap Scanning

```bash
nmap -sV -p 111 --script=rpcinfo <ip>
nmap -sV -p 2049 --script=nfs* <ip>
```

## Related Notes

- [[02-Scanning/Port-Scanning-Enhanced]] → Nmap port scanning
- [[03-Enumeration/SMB-Enumeration]] → Similar protocol enumeration
