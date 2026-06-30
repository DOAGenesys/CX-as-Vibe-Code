# Vibe Code Scripts

These scripts are reusable helpers for local review and drift checks. They do not set credentials, hardcode environment values, or apply Terraform.

## Requirements

- Terraform CLI available on `PATH`.
- Credentials supplied by the shell, secret store, or CI/CD runner.
- Run from a terminal with access to the target Terraform directory.
- Agents must not read `.env.local` or other local secret files. Load credentials into the shell yourself before asking an agent to run these scripts.

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
