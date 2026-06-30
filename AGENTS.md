# Repository Agent Instructions

## Mission

Maintain Genesys Cloud CX as Code through reviewable, Terraform-first changes.

## Primary Skill

Use the portable Vibe Code skill for Genesys Cloud work:

`skills/vibe-code/SKILL.md`

This is the canonical source for Terraform, Architect flow YAML, brownfield export, validation, smoke testing, drift detection, promotion, and rollback guidance. Agent-specific wrappers in `.cursor/skills/`, `.claude/skills/`, and `.codex/skills/` should all defer to it.

## Always Do

- Treat Terraform with provider source `mypurecloud/genesyscloud` as the source of truth for supported Genesys Cloud resources.
- Keep Architect flows in YAML and manage lifecycle with `genesyscloud_flow`.
- Use SDK, CLI, or REST checks for verification and diagnostics, not as the normal mutation path.
- Reuse existing modules, naming patterns, and environment structure before creating new patterns.
- Discover current `genesyscloud_*` resources, data sources, arguments, permissions, and scopes from the installed provider schema and current provider docs before adding provider-specific HCL.
- Run or recommend Terraform formatting, validation, plan, and focused smoke tests for relevant changes.
- Keep the smallest reviewable diff.
- Treat `.env.local` and any `.env*` secret file as user-managed and off-limits; use only environment variable names and presence checks.

## Never Do

- Never hardcode OAuth client IDs, OAuth client secrets, tokens, backend credentials, org GUIDs, queue IDs, or division IDs.
- Never read, print, summarize, edit, or ask the user to paste `.env.local` or any other local secret file.
- Never commit Terraform state, plan files, exported secrets, or credential material.
- Never mutate Genesys Cloud directly through SDK, CLI, or REST unless the user explicitly approves a documented exception.
- Never invent `genesyscloud_*` resources, arguments, or data sources from memory or from old examples.
- Never rename Architect flows or enable `force_unlock` without calling out the replacement and publication risks.
- Never add or edit `.github/workflows/` unless the user explicitly asks for GitHub Actions.

## Definition Of Done

- Requested scope only.
- Terraform or flow changes are validated where possible.
- Plan review notes include blast radius and replacement risk.
- Smoke tests or post-deploy checks are added or recommended when behavior changes.
- Rollback path is documented for risky changes.
