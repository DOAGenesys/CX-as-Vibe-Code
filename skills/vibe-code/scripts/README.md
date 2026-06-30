# Vibe Code Scripts

These scripts are reusable helpers for local review, provider discovery, drift checks, and approved Terraform runs.

## Requirements

- Terraform CLI available on `PATH`.
- Credentials supplied by the shell, secret store, or CI/CD runner.
- Run from a terminal with access to the target Terraform directory.
- Agents must not read, print, or parse `.env.local` with ad hoc commands. The only approved `.env.local` access path is `terraform-local-env.ps1`, which loads allowed variables internally without printing values.

## Terraform Review

Runs `fmt`, `init`, `validate`, and optionally `plan`:

```powershell
./scripts/terraform-review.ps1 -TerraformDir "infra/environments/dev"
```

Skip the plan step when credentials are unavailable:

```powershell
./scripts/terraform-review.ps1 -TerraformDir "infra/environments/dev" -SkipPlan
```

Pass additional plan arguments as an array:

```powershell
./scripts/terraform-review.ps1 -TerraformDir "infra/environments/dev" -PlanArgs @("-var-file=dev.tfvars")
```

## Terraform With Local Env

Loads allowed variable names from `.env.local` and runs a Terraform command without printing secret values. Only `GENESYSCLOUD_*` and `TF_VAR_*` names are loaded.

Plan to a reviewed plan file:

```powershell
./scripts/terraform-local-env.ps1 `
  -TerraformDir "infra/environments/dev" `
  -TerraformCommand plan `
  -TerraformArgs @("-out=tfplan")
```

Apply the reviewed plan file after explicit approval:

```powershell
./scripts/terraform-local-env.ps1 `
  -TerraformDir "infra/environments/dev" `
  -TerraformCommand apply `
  -TerraformArgs @("tfplan") `
  -AllowApply
```

Do not use this script to bypass review. It exists only so agents can run Terraform with local credentials loaded at runtime without seeing the credential values.

## Provider Discovery

Lists current Genesys Cloud resources from the installed provider schema:

```powershell
./scripts/provider-discovery.ps1 -TerraformDir "infra/environments/dev"
```

Include data sources:

```powershell
./scripts/provider-discovery.ps1 -TerraformDir "infra/environments/dev" -IncludeDataSources
```

Filter by name:

```powershell
./scripts/provider-discovery.ps1 -TerraformDir "infra/environments/dev" -Search "routing"
```

Run `terraform init` first if the provider has not been installed in that directory.

## Drift Check

Runs a refresh-only plan with detailed exit codes:

```powershell
./scripts/drift-check.ps1 -TerraformDir "infra/environments/prod"
```

Exit code `0` means no drift, `2` means drift was detected, and `1` means the command failed.
