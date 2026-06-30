# Brownfield Onboarding

## Goal

Use `genesyscloud_tf_export` to start from real Genesys Cloud org configuration, then normalize the export into maintainable Terraform without changing behavior.

## When To Use

Use this workflow when:

- The target org already contains manually managed queues, flows, integrations, roles, or deployments.
- The user asks to migrate an existing org into Terraform.
- A change depends on current org structure that is not represented in the repository.
- The agent would otherwise need to invent resource names, IDs, or relationships.

## Safe Sequence

1. Confirm the export target resource families and environment.
2. Create a narrowly scoped export configuration.
3. Run the export in a non-production or approved environment first when possible.
4. Review exported HCL and state sensitivity before committing anything.
5. Replace externally managed dependencies with data sources.
6. Extract repeated patterns into modules only after confirming exported behavior.
7. Run `terraform fmt`, `terraform validate`, and a plan before proposing apply.

## Export Template

Use a narrow include list and split files by resource when normalizing a large org:

```hcl
provider "genesyscloud" {}

resource "genesyscloud_tf_export" "brownfield" {
  directory               = "./exported"
  export_format           = "hcl"
  include_state_file      = true
  log_permission_errors   = true
  split_files_by_resource = true

  include_filter_resources = [
    "genesyscloud_routing_queue::.*",
    "genesyscloud_flow::.*"
  ]
}
```

For flow-focused exports, prefer the current Architect flow exporter when supported by the pinned provider:

```hcl
resource "genesyscloud_tf_export" "flows" {
  directory                          = "./exported"
  export_format                      = "hcl"
  include_filter_resources           = ["genesyscloud_flow::.*"]
  use_legacy_architect_flow_exporter = false
}
```

## Normalization Rules

- Preserve resource identities and names unless the user explicitly requested a rename.
- Do not refactor exported resources and change behavior in the same step.
- Use data sources for existing shared objects that should stay externally managed.
- Keep flow YAML structure readable and substitution-friendly.
- Document any unresolved references, omitted state, or permission errors before proceeding.

## Red Flags

Stop and ask before proceeding if:

- The export requires broad production permissions.
- `include_state_file = true` would commit state or sensitive values.
- The plan shows flow replacement, deletion, or unexpected role changes.
- The export includes preview resources or objects outside the requested scope.
