# Claude Code Instructions

Use the repository-level instructions in `AGENTS.md`.

For Genesys Cloud CX as Code tasks, load the portable Vibe Code skill from:

`skills/vibe-code/SKILL.md`

The Claude Code wrapper at `.claude/skills/vibe-code/SKILL.md` exists only to help Claude discover the shared skill. The canonical instructions and references live in `skills/vibe-code/`.

Do not apply Terraform, mutate Genesys Cloud, or introduce CI/CD automation without explicit user approval and a clear target platform.

Never read, print, summarize, edit, or ask the user to paste `.env.local` or any other local secret file. Use only environment variable names, presence checks, or the audited `skills/vibe-code/scripts/terraform-local-env.ps1` runner when Terraform needs local credentials.
