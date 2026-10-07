# Engagement Workflow

This workflow turns technique notes into a controlled penetration test. The signed Rules of Engagement (RoE) always takes precedence.

## 1. Authorization gate

Do not send traffic until all items are confirmed:

- legal entity, asset owner, and written authorization;
- exact in-scope addresses, domains, applications, tenants, and accounts;
- excluded systems and prohibited techniques;
- test window, source addresses, rate limits, and concurrency limits;
- emergency contact, stop word, and abort conditions;
- rules for social engineering, persistence, credential access, data extraction, and denial-of-service testing;
- evidence retention, encryption, transfer, and deletion dates.

Use [[templates/Rules-of-Engagement]] as the minimum record.

## 2. Engagement workspace

Create a customer-specific workspace outside this repository. Record UTC timestamps, operator, source IP, command, tool version, target, result, and evidence path for every material action. Never store live credentials or customer data in this Git repository.

Recommended evidence naming:

```text
YYYYMMDDTHHMMSSZ_target_technique_operator.ext
```

Hash collected evidence when acquired and after transfer. Restrict access to the engagement team.

## 3. Reconnaissance and scan gate

Start with passive collection. Before active scanning, verify the target against the scope allowlist and apply the approved packet rate, parallelism, source IP, and time window. Establish a low-rate baseline before increasing load. Stop on instability, unexpected ownership, or an emergency-contact request.

## 4. Validation gate

For each suspected issue:

1. State the hypothesis and lowest-impact proof.
2. Confirm the asset and test account are authorized.
3. Capture the before-state and prepare rollback.
4. Execute the smallest proof that establishes impact.
5. Stop after proof; avoid unnecessary data access.
6. Record evidence, affected object, timestamp, and cleanup action.

Actions involving persistence, endpoint-protection changes, credential dumping, lateral movement, domain-wide privileges, production writes, or data extraction require explicit RoE approval and deconfliction immediately before execution.

## 5. Finding quality gate

A reportable finding needs a reproducible path, affected asset, prerequisite, evidence, impact, root cause, and concrete remediation. Separate verified facts from assumptions. Use [[templates/Finding]] and redact secrets, personal data, tokens, and customer identifiers from screenshots and command output.

## 6. Cleanup and restoration

Maintain an artifact register throughout the engagement. Remove only artifacts created by the team, using exact paths and object names. Restore configuration from captured before-values. Preserve customer telemetry unless the RoE explicitly authorizes a controlled detection exercise. Obtain system-owner verification for high-impact rollback.

## 7. Closeout

- confirm all tunnels, listeners, accounts, tasks, services, rules, and persistence are removed;
- deliver the cleanup register and unresolved items;
- transfer the report and evidence over the agreed channel;
- revoke test credentials and access;
- destroy retained customer data on schedule and record the deletion.
