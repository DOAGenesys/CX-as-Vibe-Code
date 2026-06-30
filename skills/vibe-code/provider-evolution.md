# Provider Evolution

## Principle

The skill is policy, workflow, and safety guidance. It is not a complete resource catalog.

For every Genesys Cloud Terraform change, treat the active Terraform provider schema and the current provider docs as the source of truth for resources, data sources, arguments, permissions, scopes, and behavior notes.

## Dynamic Discovery Order

1. Read the repository's Terraform provider constraint and `.terraform.lock.hcl` when present.
2. Run `terraform init` in the relevant Terraform directory if the provider is not installed.
3. Inspect the installed provider schema with:

```bash
terraform providers schema -json
```

4. Check current docs for the specific resource or data source:

```text
https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs
```

5. Review the provider release notes when a requested feature appears to need a newer provider.
6. Validate generated HCL with `terraform validate` and review the plan before proposing apply.

## Version Strategy

- Pin provider versions in repositories; do not use unbounded `latest` behavior for production infrastructure.
- Prefer controlled upgrades in a separate, reviewable change.
- Use `terraform init -upgrade` only when the user asks to evaluate or perform a provider upgrade.
- After upgrading, run `terraform validate`, `terraform plan`, and focused smoke tests.
- If the provider no longer supports an argument or behavior used by the repo, stop and propose a migration plan.

## Agent Rules

- Do not assume the examples in this skill represent the full provider surface.
- Do not invent `genesyscloud_*` resources, arguments, or data sources from memory.
- Do not use SDK, CLI, or REST mutation as a substitute just because the skill examples do not mention a provider resource.
- If the installed provider lacks a needed resource but live docs show it exists in a newer version, propose a provider upgrade with blast radius and validation notes.
- If live docs do not show provider coverage, use SDK, CLI, or REST only as a documented exception and keep Terraform as the desired-state authority wherever possible.

## Maintenance-Free Posture

To remain useful without regular skill edits, agents must refresh provider facts at task time. The stable parts of this skill are:

- Terraform-first operating model.
- Secrets and state handling.
- Brownfield export workflow.
- Validation, plan review, promotion, and rollback.
- Rules for dynamic provider discovery.

The unstable parts belong outside the skill and must be fetched or inspected when needed:

- Resource and data source availability.
- Argument names and nested schemas.
- Permissions and OAuth scopes.
- Provider defaults and behavior notes.
- New deprecations or migration guidance.
