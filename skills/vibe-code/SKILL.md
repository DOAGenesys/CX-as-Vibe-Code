---
name: vibe-code
description: Guides coding agents to create, refactor, validate, and prepare Genesys Cloud CX as Code changes safely using Terraform, Architect YAML, official SDK or CLI checks, brownfield exports, drift checks, and approval-gated promotion. Use for Genesys Cloud Terraform, Architect flow YAML, CX as Code, Vibe Code, brownfield onboarding, smoke testing, rollback, or promotion tasks.
---

# Vibe Code

## When To Use

Use this skill for Genesys Cloud infrastructure changes, Terraform refactors, Architect flow YAML work, brownfield exports, CI/CD planning, drift checks, smoke tests, promotion reviews, and rollback preparation.

This skill is intentionally agent agnostic. Cursor, Claude Code, Codex, and other coding agents should all treat this directory as the canonical Vibe Code skill.

## Operating Model

- Treat Terraform with provider source `mypurecloud/genesyscloud` as the desired-state authority for supported Genesys Cloud resources.
- Keep Architect flows as YAML artifacts and manage their lifecycle through `genesyscloud_flow`.
- Use official SDKs, CLI, or REST calls for inspection, diagnostics, smoke tests, and unsupported edge cases, not as the default mutation path.
- Keep all OAuth credentials, backend credentials, API tokens, org IDs, and secrets out of committed files.
- Treat `.env.local` and other `.env*` secret files as user-managed and off-limits. Do not read, print, summarize, edit, or ask the user to paste them.
- Use remote state with locking and serialize applies per workspace or backend.
- Require human review before production applies and before flow rename, force unlock, or destructive replacement risks.
- Do not add or edit `.github/workflows/` unless the user explicitly asks for GitHub Actions. Ask which CI/CD platform the project uses when automation is needed.

## Workflow

1. Read the local repository structure and existing Terraform, flow YAML, tests, and guidance files.
2. Identify the minimum module, environment, flow, or test surface required for the change.
3. Discover current provider capabilities from the installed provider schema and current provider docs before adding or changing `genesyscloud_*` resources.
4. For brownfield orgs, prefer `genesyscloud_tf_export` to bootstrap real configuration before hand-authoring resources.
5. Use existing modules and naming patterns before creating new structure.
6. Represent supported resource changes in Terraform; use data sources for existing objects that should be referenced but not managed.
7. Keep direct SDK, CLI, or REST mutation scripts out of the normal deployment path.
8. Add or update focused Terraform tests or SDK smoke checks when behavior changes.
9. Prepare promotion notes that include blast radius, plan-review focus, approval needs, rollback path, and drift risk.

## Required Checks

For Terraform changes, run or recommend the closest applicable checks:

```bash
terraform fmt -check -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Use `terraform test` when `.tftest.hcl` files exist or when adding module-level assertions. After lower-environment applies, use official SDK or CLI smoke tests to verify the deployed Genesys Cloud objects that matter to the change.

## Stop And Ask

Stop and ask the user before:

- Applying Terraform or running a command that mutates a live Genesys Cloud org.
- Creating broad new CI/CD automation without knowing the platform in use.
- Renaming Architect flows or enabling `force_unlock`.
- Introducing preview APIs or direct API mutations for production behavior.
- Storing any value that might be secret or state-sensitive in Terraform, docs, scripts, or logs.
- Inspecting `.env.local` or any other local secret file. Check only whether required environment variable names are present in the current process.

## Reference Files

- Use [provider-cheatsheet.md](provider-cheatsheet.md) for Terraform provider, resource, SDK, CLI, and permission guidance.
- Use [provider-evolution.md](provider-evolution.md) before adding new provider resources, changing provider versions, or relying on provider behavior.
- Use [brownfield-onboarding.md](brownfield-onboarding.md) when importing or normalizing an existing Genesys Cloud org.
- Use [validation-and-release.md](validation-and-release.md) for validation, smoke testing, drift detection, promotion, and rollback.
- Use [examples.md](examples.md) for safe prompt patterns and review templates.
- Use [scripts/README.md](scripts/README.md) before running helper scripts.
