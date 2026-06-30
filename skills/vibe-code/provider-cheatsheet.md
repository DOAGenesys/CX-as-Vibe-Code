# Genesys Cloud Provider Cheatsheet

## Canonical Tools

- Terraform provider: `mypurecloud/genesyscloud`
- Architect flow source: YAML referenced by `genesyscloud_flow`
- Export bootstrap: `genesyscloud_tf_export`
- Verification tools: official Genesys Cloud SDKs, Platform API CLI, or read-only REST checks

## Provider Rules

- Configure authentication through environment variables or the runtime secret store.
- Do not hardcode OAuth client IDs, OAuth client secrets, backend credentials, access tokens, queue IDs, org GUIDs, or division IDs.
- Do not read, print, summarize, edit, or ask the user to paste `.env.local` or any other local secret file.
- Pin the provider version in Terraform and review current provider docs before adding newer resources.
- Treat the installed provider schema and live Registry docs as authoritative. Do not rely on this cheatsheet as a complete resource catalog.
- Use provider resource docs to derive required OAuth scopes and Genesys Cloud permissions.
- Keep `token_pool_size` and pagination concurrency conservative unless the repo already tunes them.
- Treat Terraform state as sensitive because managed resources can expose sensitive values through state.

## Common Resource Families

This list is illustrative and may lag the provider. Discover current coverage from the installed provider schema and live docs.

- Routing: queues, skills, languages, wrap-up codes, utilization, schedules.
- Authorization and OAuth: roles, divisions, role grants, OAuth clients.
- Architect: flows through `genesyscloud_flow` with YAML files and substitutions.
- Integrations and Data Actions: integrations, credentials, actions, draft and publish behavior.
- Messaging and web: deployments, messenger config, supported channel resources.
- AI and workforce features: verify entitlement and provider coverage before standardizing.

## Architect Flow Rules

- Keep flow YAML under version control and reference it from Terraform.
- Use substitutions for environment-specific names and IDs.
- Flag any flow rename because changing a flow name can create a new GUID while the original remains.
- Flag `force_unlock` because it can publish drafts as part of unlocking and publishing behavior.
- Prefer exporting existing flows with the current exporter path when onboarding brownfield orgs.

## SDK, CLI, And REST Usage

Use SDKs, CLI, or REST for:

- Post-deploy smoke tests.
- Inventory and diagnostics.
- Drift investigation.
- Unsupported read paths.
- Narrow, documented exceptions where Terraform provider coverage is missing.

Do not use SDK, CLI, or REST scripts as a parallel deployment system when the Terraform provider supports the resource.

## Least-Privilege Checklist

- Use separate OAuth clients per environment.
- Split deploy permissions from smoke-test permissions when their access differs.
- Scope roles to the managed resource families and divisions.
- Review provider docs for resource-specific permissions and OAuth scopes.
- Avoid broad admin roles for automation lanes.
- Rotate credentials through the secret manager or CI/CD platform, not by committing new values.
