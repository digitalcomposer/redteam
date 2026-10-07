---
tags: [covering-tracks, index, opsec]
---

# Controlled Cleanup — Index

> [!WARNING]
> Preserve customer telemetry and remove only artifacts created by the test team. Clearing logs, changing timestamps, disabling audit policy, or deleting broad temporary directories can destroy evidence and disrupt operations. Perform those actions only when the signed RoE defines a controlled detection objective and the customer authorizes the exact host, time window, and rollback plan.

## Notes in This Section

| Note | Content |
|------|---------|
| [[09-Covering-Tracks/Linux-Log-Removal]] | bash_history, auth.log, syslog, wtmp, timestamps |
| [[09-Covering-Tracks/Windows-Log-Removal]] | wevtutil, auditpol, PowerShell logs, prefetch |
| [[09-Covering-Tracks/Artifact-Cleanup]] | Full pre-cleanup inventory, verification checklist |

## Cleanup standard

1. Freeze testing and notify the engagement contact.
2. Export the operator-created artifact register and capture final evidence.
3. Remove exact files, accounts, services, tasks, firewall rules, tunnels, and persistence created by the team.
4. Restore changed settings from recorded before-values.
5. Verify each rollback with the system owner and record the result.
6. Preserve security logs and provide timestamps so defenders can correlate activity.

## Pre-Cleanup Checklist

```
Before leaving:
[ ] List all files you dropped (note paths)
[ ] List all users you created
[ ] List all services/tasks created
[ ] List all registry keys modified
[ ] Screenshot BloodHound / netstat / ps output for report
[ ] Run cleanup: [[09-Covering-Tracks/Artifact-Cleanup]]
```

## Evidence reminder

- Log deletion is observable and can violate evidence-retention requirements.
- Timestamp manipulation weakens auditability and should not be part of routine cleanup.
- Broad wildcard deletion can remove customer data. Delete only exact, registered paths.

## Related

- [[00-Reference/OPSEC]] — OPSEC guidance
- [[09-Methodologies/Full Checklist]] — Phase 10: Cleanup
