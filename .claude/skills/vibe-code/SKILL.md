---
name: vibe-code
description: Loads the portable Vibe Code skill for Genesys Cloud CX as Code work. Use for Genesys Cloud Terraform, Architect flow YAML, Functions, Function Data Actions, backend custom Node.js code, CX as Code, brownfield onboarding, smoke testing, drift checks, rollback, or promotion tasks in Claude Code.
---

# Vibe Code For Claude Code

This is a Claude Code entry point for the portable Vibe Code skill.

Before acting, read and follow the canonical skill at:

`skills/vibe-code/SKILL.md`

Use the reference files and scripts from `skills/vibe-code/`. Do not treat this wrapper as a separate source of policy.

Never read, print, summarize, edit, or ask the user to paste `.env.local` or any other local secret file. Use only the audited `skills/vibe-code/scripts/terraform-local-env.ps1` runner when Terraform needs local credentials.
