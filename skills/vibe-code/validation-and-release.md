# Validation And Release

## Local Review

For Terraform edits, validate from the relevant environment or module directory:

```bash
terraform fmt -check -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Use `terraform test` when the repository contains `.tftest.hcl` files or when adding module assertions.

## Plan Review Checklist

- The plan changes only the requested resource families.
- No OAuth secrets, backend credentials, access tokens, or state-sensitive values are exposed.
- Existing resources that should remain unmanaged are referenced through data sources.
- Flow renames, replacements, and `force_unlock` usage are explicitly called out.
- Production changes require an approval gate.
- Applies to the same backend or workspace are serialized.

## Smoke Testing

Post-apply smoke tests should verify behavior-critical objects through official SDKs, CLI, or read-only REST calls. Keep tests focused on the change:

- Routing changes: queue existence, queue name, member or skill expectations when in scope.
- Flow changes: flow name, type, published status, and key dependencies.
- Integration, Data Action, or Function changes: action existence, status, 15 second timeout setting, expected response shape, missing-required-field behavior, and execution logs.
- Authorization changes: role and division assignments for the specific principal in scope.

## Drift Detection

Use refresh-only plans for drift checks:

```bash
terraform init -input=false
terraform plan -refresh-only -input=false -detailed-exitcode
```

Exit code `0` means no drift, `2` means drift was detected, and `1` means the command failed.

## Promotion Notes

Before promoting from dev to test or production, capture:

- Target environment and workspace or backend.
- Terraform plan summary.
- Resources with create, update, replace, or delete actions.
- Flow rename or force-unlock risk.
- Required approvals.
- Smoke tests to run after apply.
- Rollback path.

## Rollback

Prefer rollback through Git and Terraform:

1. Revert to a known-good commit.
2. Re-run plan against the target environment.
3. Apply through the normal approved path.
4. Run smoke tests after rollback.

If state drift or backend recovery is involved, take a state backup before manual state operations and document the recovery reason.
