# Firmware Analysis

**Tags:** #firmware #iot #embedded #reverse-engineering
**Phase:** Recon / Vulnerability Research

---

## Initial Triage

```bash
file firmware.bin
strings -n8 firmware.bin | head -100
strings -tx firmware.bin | head -50    # with hex offsets
hexdump -C -n 512 firmware.bin
fdisk -lu firmware.bin                 # partition table
```

## binwalk — Structure Analysis

```bash
# Scan for signatures
binwalk firmware.bin

# Extract everything
binwalk -e firmware.bin
binwalk -Me firmware.bin   # recursive + extract

# Entropy analysis (packed/encrypted regions)
binwalk -E firmware.bin
binwalk --save --entropy firmware.bin

# List file systems found
binwalk -D 'squashfs' firmware.bin
```

## Mount & Explore

```bash
# After binwalk extraction
ls _firmware.bin.extracted/

# Mount squashfs
sudo mount -t squashfs squashfs.img /mnt/firmware
ls /mnt/firmware/

# Or extract squashfs
unsquashfs squashfs.img -d squashfs_root/

# Mount ext filesystem
sudo mount -t ext4 rootfs.ext4 /mnt/firmware

# JFFS2
modprobe jffs2
modprobe mtdram total_size=65536 erase_size=256
modprobe mtdblock
dd if=rootfs.jffs2 of=/dev/mtdblock0
mount -t jffs2 /dev/mtdblock0 /mnt/firmware
```

## Credential Hunting in Firmware

```bash
cd squashfs_root/

# Hashed passwords
cat etc/passwd
cat etc/shadow

# Hardcoded credentials
grep -rn "password\|passwd\|admin\|root\|secret\|key" etc/ 2>/dev/null
grep -rn "password" var/ www/ 2>/dev/null

# SSL certificates / private keys
find . -name "*.pem" -o -name "*.key" -o -name "*.crt" 2>/dev/null
find . -name "id_rsa" 2>/dev/null

# Config files
cat etc/config/* 2>/dev/null
find . -name "*.conf" -o -name "*.cfg" 2>/dev/null | xargs grep -l "pass"
```

## Emulation

```bash
# QEMU — emulate firmware
# ARM
qemu-arm-static -L . ./sbin/init

# MIPS
qemu-mips-static -L . ./sbin/init

# Full system emulation with FirmAE
git clone https://github.com/pr0v3rbs/FirmAE
./run.sh -r brand firmware.bin

# firmwalker — automated firmware analysis
git clone https://github.com/craigz28/firmwalker
./firmwalker.sh squashfs_root/
```

## Dynamic Analysis

```bash
# After emulation — run web interface
curl http://192.168.0.1/
# Look for:
# - Default credentials
# - Command injection in web interface
# - Buffer overflows in binaries
# - Unencrypted update mechanism

# Decrypt update files
strings firmware_update.bin | grep -i "key\|aes\|rsa"
openssl enc -d -aes-256-cbc -in encrypted.bin -out decrypted.bin -k PASSWORD
```

## Tools

| Tool | Purpose |
|------|---------|
| binwalk | Firmware analysis + extraction |
| firmwalker | Automated secret finding |
| FirmAE | Full emulation |
| firmlyzer | Vulnerability scanner |
| FACT (Firmware Analysis Comparison Tool) | Web-based analysis |
| qemu | Binary/system emulation |
| radare2 / Ghidra | Binary reverse engineering |

## Related Notes

- [[00-Quick-Reference/Python]] — Python for scripting analysis
- [[06-Exploitation/Manual-Exploitation]] — Exploit after finding vulns
