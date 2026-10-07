# Contributing

Contributions should make the vault safer and more useful during authorized engagements.

## Content standard

- State prerequisites, privileges, expected output, operational impact, and rollback for techniques that change a target.
- Use placeholders such as `<target>`, `<domain>`, and `<lhost>`; never commit real customer data, credentials, tokens, hashes, or private keys.
- Prefer low-impact discovery and the smallest proof that demonstrates a finding.
- Do not present broad deletion, log clearing, defense disabling, persistence, spraying, or high-rate scanning as a default action.
- Replace download-and-execute pipelines with download, integrity verification, review, and explicit execution.
- Mark commands requiring explicit RoE approval.
- Link to the canonical note instead of copying long command blocks into several files.

## Navigation

Use Obsidian wikilinks without the `.md` suffix. Prefer repository-root-relative links when duplicate note names exist. Every new phase note must be linked from its section `INDEX.md`.

## Review checklist

- all linked notes exist;
- examples use placeholders;
- commands are syntactically complete;
- destructive effects and rollback are visible before the command;
- tool names and options match current upstream documentation;
- claims distinguish verified behavior from operator assumptions.

Run the repository quality gate before submitting:

```bash
ruby scripts/check-vault.rb
```
