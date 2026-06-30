# CX as Vibe Code

This repository contains an agent-agnostic Vibe Code skill pack for Genesys Cloud CX as Code.

## Install With Skills CLI

After this repository is public on GitHub, users can install the skill with the Skills CLI:

```bash
npx skills add DOAGenesys/CX-as-Vibe-Code --skill vibe-code
```

The full GitHub URL form is also acceptable if preferred:

```bash
npx skills add https://github.com/DOAGenesys/CX-as-Vibe-Code --skill vibe-code
```

The skill name is `vibe-code`, defined in `skills/vibe-code/SKILL.md`.

## Start Using The Skill

1. Open this repository with your coding agent.
2. Tell the agent to use the Vibe Code skill. Example:

```text
Use the Vibe Code skill at skills/vibe-code/SKILL.md.
Help me make a safe Genesys Cloud CX as Code change.
Do not apply Terraform or mutate Genesys Cloud unless I explicitly approve it.
```

3. The agent should automatically discover the right entry point:

- Cursor: `.cursor/skills/vibe-code/SKILL.md` and `.cursor/rules/genesys-cloud-cx-as-code.mdc`
- Claude Code: `CLAUDE.md` and `.claude/skills/vibe-code/SKILL.md`
- Codex-style agents: `AGENTS.md` and `.codex/skills/vibe-code/SKILL.md`
- Other agents: `AGENTS.md` and `skills/vibe-code/SKILL.md`

4. Before asking the agent to run Terraform plans or smoke checks, make sure the local shell or CI runner has the required tools and credentials.

## Required Local Setup

Install or provide:

- Terraform CLI on `PATH`.
- Git, so the agent can review diffs.
- Access to the target Terraform working directory, such as `infra/environments/dev`.
- A configured remote Terraform backend when working with shared environments.
- Optional: Genesys Cloud SDK, CLI, or Archy when the specific task needs smoke tests, diagnostics, or Architect flow tooling.

Do not commit credentials to this repository. Real local values belong in `.env.local`, which is ignored by Git. Agents must never open, print, summarize, or edit `.env.local`. When a Terraform command needs local credentials, use the audited helper script at `skills/vibe-code/scripts/terraform-local-env.ps1`; it loads allowed variables internally without printing values.

Create your local file from the safe template:

```powershell
Copy-Item .env.example .env.local
```

Then edit `.env.local` yourself with values from your secret store. Do not paste real values into agent chat.

Example `.env.local` shape:

```dotenv
GENESYSCLOUD_OAUTHCLIENT_ID=your-client-id
GENESYSCLOUD_OAUTHCLIENT_SECRET=your-client-secret
GENESYSCLOUD_REGION=us-east-1
```

For your own manual terminal work, prefer an OS-level environment variable, terminal profile, password manager, CI/CD secret injection, or another secret-store-backed loader. If you use PowerShell manually, run this yourself outside agent control and load values without printing them:

```powershell
Get-Content .env.local | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $name, $value = $_ -split '=', 2
  [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), 'Process')
}
```

Only the variable names should appear in prompts, logs, or docs. Do not ask the agent to inspect, source, parse, or print `.env.local` with ad hoc commands. Ask it to use `terraform-local-env.ps1` when Terraform needs local credentials.

For Terraform with the Genesys Cloud provider, the usual environment variables are:

```powershell
$env:GENESYSCLOUD_OAUTHCLIENT_ID
$env:GENESYSCLOUD_OAUTHCLIENT_SECRET
$env:GENESYSCLOUD_REGION
```

Use the Genesys Cloud region that matches your org. Keep separate OAuth clients and secrets per environment, such as dev, test, and prod. The OAuth client should use the client-credentials grant and only the roles, divisions, permissions, and scopes needed for the resource families being managed.

If your Terraform backend also needs credentials, provide those through the backend's normal environment variables or your CI/CD secret integration. Do not hardcode backend credentials in `.tf` files, `*.tfvars`, Markdown files, or agent prompts.

Rotate OAuth client secrets and backend credentials on a regular schedule, and rotate immediately if a secret may have been exposed in chat, logs, state, a plan artifact, or a committed file. After rotation, update only your secret store, CI/CD variables, or local `.env.local`.

## First Safe Validation

Start with read-only or plan-only work. For example:

```powershell
.\skills\vibe-code\scripts\terraform-review.ps1 -TerraformDir "infra/environments/dev" -SkipPlan
```

When credentials and backend access are ready, allow a plan:

```powershell
.\skills\vibe-code\scripts\terraform-review.ps1 -TerraformDir "infra/environments/dev"
```

If credentials are only in `.env.local`, use the safe local-env runner instead:

```powershell
.\skills\vibe-code\scripts\terraform-local-env.ps1 `
  -TerraformDir "infra/environments/dev" `
  -TerraformCommand plan `
  -TerraformArgs @("-out=tfplan")
```

Apply only a reviewed plan, after explicit approval:

```powershell
.\skills\vibe-code\scripts\terraform-local-env.ps1 `
  -TerraformDir "infra/environments/dev" `
  -TerraformCommand apply `
  -TerraformArgs @("tfplan") `
  -AllowApply
```

For drift checks:

```powershell
.\skills\vibe-code\scripts\drift-check.ps1 -TerraformDir "infra/environments/prod"
```

These helper scripts do not apply Terraform. The agent should stop and ask before any command that mutates a live Genesys Cloud org.

## Provider Evolution

The Genesys Cloud Terraform provider changes over time. This skill is designed to stay useful by making agents discover provider facts dynamically instead of relying on a static resource list in the skill.

For any new or changed `genesyscloud_*` resource, the agent should:

1. Check the repository's pinned provider version and `.terraform.lock.hcl` when present.
2. Run `terraform init` in the relevant Terraform directory if the provider is not installed.
3. Inspect the installed provider schema:

```powershell
terraform providers schema -json
```

4. Check the current Registry docs for the specific resource or data source:

```text
https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs
```

5. Review provider release notes before proposing an upgrade.
6. Validate with `terraform validate` and review `terraform plan`.

You can list resources exposed by the installed provider with:

```powershell
.\skills\vibe-code\scripts\provider-discovery.ps1 -TerraformDir "infra/environments/dev" -IncludeDataSources
```

Do not use unbounded latest-provider behavior for production infrastructure. Pin provider versions and upgrade intentionally in a small, reviewable change.

## Canonical Skill

The shared skill lives here:

```text
skills/vibe-code/
├── SKILL.md
├── provider-cheatsheet.md
├── provider-evolution.md
├── brownfield-onboarding.md
├── validation-and-release.md
├── examples.md
└── scripts/
    ├── README.md
    ├── terraform-review.ps1
    ├── terraform-local-env.ps1
    ├── provider-discovery.ps1
    └── drift-check.ps1
```

All coding agents should treat `skills/vibe-code/SKILL.md` as the source of truth.

## Agent Entry Points

- Generic and Codex-style repository instructions: `AGENTS.md`
- Claude Code repository instructions: `CLAUDE.md`
- Cursor project skill: `.cursor/skills/vibe-code/SKILL.md`
- Cursor project rule: `.cursor/rules/genesys-cloud-cx-as-code.mdc`
- Claude Code skill wrapper: `.claude/skills/vibe-code/SKILL.md`
- Codex-style skill wrapper: `.codex/skills/vibe-code/SKILL.md`

The wrapper files exist only for discovery. The actual workflow, references, and helper scripts live in `skills/vibe-code/`.

## Core Operating Model

- Terraform with `mypurecloud/genesyscloud` is the source of truth for supported Genesys Cloud resources.
- Architect flows stay as YAML and are managed through `genesyscloud_flow`.
- SDK, CLI, and REST usage is for verification, diagnostics, and documented exceptions.
- Secrets and state-sensitive values must never be committed.
- Production applies require human approval and serialized Terraform state access.
