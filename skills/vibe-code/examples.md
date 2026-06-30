# Examples

## Safe Change Prompt

```text
Use the Vibe Code skill.

Task:
Add the requested Genesys Cloud configuration change using Terraform and flow YAML where applicable.

Rules:
- Terraform-first for supported resources.
- Reuse existing modules and naming patterns.
- Do not mutate Genesys Cloud directly through SDK, CLI, or REST.
- Do not hardcode OAuth clients, secrets, tokens, backend credentials, GUIDs, or environment-specific IDs.
- Add or update focused smoke tests when behavior changes.
- Stop and explain before flow rename, force unlock, replacement, or destructive changes.

Output:
- Files changed.
- Validation commands.
- Plan review notes.
- Rollback notes.
```

## Brownfield Refactor Prompt

```text
Use the Vibe Code skill and brownfield onboarding workflow.

Task:
Normalize the exported Genesys Cloud Terraform into maintainable modules without changing live behavior.

Rules:
- Preserve resource names and identities.
- Use data sources for dependencies that should stay externally managed.
- Do not change backend, secrets handling, or flow names.
- Keep the first refactor narrow and reviewable.
- Run or recommend fmt, validate, and plan.
```

## Failed Flow Deploy Prompt

```text
Use the Vibe Code skill.

Task:
Investigate the failed Architect flow deployment and propose the smallest safe corrective patch.

Check:
- Terraform diff.
- genesyscloud_flow filepath and substitutions.
- Flow rename risk.
- force_unlock usage.
- Provider version and export history.

Do not apply anything directly.
```

## Plan Review Template

```markdown
## Summary

[Describe the Genesys Cloud behavior change.]

## Terraform Plan Focus

- Creates:
- Updates:
- Replaces:
- Deletes:

## Safety Notes

- Secrets/state exposure:
- Flow rename or force unlock:
- Direct API mutation:
- Preview API usage:
- Approval requirements:

## Validation

- `terraform fmt -check -recursive`
- `terraform init -input=false`
- `terraform validate`
- `terraform plan -input=false`
- Smoke tests:

## Rollback

[Describe the known-good commit or state-backed recovery path.]
```
