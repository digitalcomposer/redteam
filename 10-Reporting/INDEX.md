# Reporting and Closeout

Reporting starts during reconnaissance, not after exploitation.

## Required records

- [[templates/Evidence-Register]] — Evidence IDs, timestamps, provenance, integrity, and storage
- [[templates/Artifact-Register]] — Created or changed objects and rollback status
- [[templates/Finding]] — Reproduction, evidence, impact, root cause, remediation, and retest
- [[templates/Rules-of-Engagement]] — Authorization and operating limits

## Finding lifecycle

1. **Candidate** — observation needs validation.
2. **Validated** — smallest authorized proof confirms the weakness.
3. **Triaged** — affected scope, prerequisites, impact, severity, and duplicates resolved.
4. **Reported** — evidence is redacted, reproducible, and mapped to remediation.
5. **Retested** — secure behavior verified or residual risk documented.
6. **Closed** — customer accepts the result and evidence follows retention policy.

## Severity inputs

Consider attacker position, required privileges, user interaction, exploit reliability, affected asset criticality, blast radius, persistence, detectability, and demonstrated confidentiality, integrity, or availability impact. Record environmental assumptions instead of relying on a numeric score alone.

## Deliverables

- executive summary and overall risk narrative;
- scope, exclusions, assumptions, test window, and limitations;
- attack-path narrative showing how findings combine;
- technical findings with evidence and remediation priorities;
- positive controls and rejected hypotheses where useful;
- cleanup and restoration attestation;
- unresolved access, artifacts, or customer-owned actions;
- retest status and residual risk;
- evidence retention and destruction date.

## Quality gate

Every reported finding must answer:

- What exact asset and security boundary failed?
- Who can reproduce it and with which prerequisites?
- What was directly demonstrated?
- Which evidence proves the claim without exposing unnecessary customer data?
- What implementation or configuration caused it?
- What specific fix and regression check close it?
