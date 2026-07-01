# Genesys Cloud Functions

## When To Use

Use this reference whenever the user asks for Genesys Cloud Functions, Function Data Actions, simulated external web services, or backend custom Node.js code intended to run inside Genesys Cloud.

Functions are short-lived serverless handlers. Always design and configure them for a 15 second timeout, which is the maximum. Do not introduce long polling, sleeps, retries that can exceed the budget, background jobs, persistent servers, or external dependencies unless the user explicitly asks and the timeout risk is documented.

## Operating Rules

- Generate vanilla Node.js only unless the user explicitly asks for a library.
- Use Node `>=22`, CommonJS, and `exports.handler = async (event) => { ... }`.
- Keep `"dependencies": {}` unless the user asks for libraries.
- Use `crypto.randomUUID()` for fake IDs.
- Emit all datetimes in ISO-8601 UTC, for example `2025-07-29T14:30:00Z`.
- Include the logging helper exactly as shown and keep `console.log` usage:

```js
const createLog = (level, message, details = {}) =>
  console.log(JSON.stringify({ level, message, ...details, timestamp: new Date().toISOString() }));
```

- Treat the function as a simulation of an external web service unless the user explicitly requests real integrations.
- Keep logic simple, deterministic where practical, and fast enough to finish comfortably inside 15 seconds.
- Never hardcode credentials, tokens, org GUIDs, queue IDs, division IDs, or customer secrets.

## Requirement Gathering

Ask one question at a time. If the user already provided all four answers, skip the questions and implement.

1. `What is the function name?`
2. `List all input parameters with type and description.`
3. `Describe the desired output structure.`
4. `Explain the core logic or behaviour to simulate.`

For CRUD or deployment work, gather only the missing deployment facts after the function requirements are known:

- Target operation: create, read, update, delete, or replace.
- Target environment and Terraform directory, if Terraform manages the action.
- Existing Function Data Actions integration name or whether one should be created.
- Action/function name and category.
- Whether the change should remain a draft or be prepared for publish.

Do not mutate Genesys Cloud, upload a function bundle, publish an action, or delete an action without explicit user approval.

## Generated Output Contract

When the user asks you to generate a function artifact in chat, output exactly four labeled fenced code blocks in this order:

1. `package.json`
2. `src/index.js`
3. `Input contract`
4. `Output contract`

Use the label immediately above each fenced block. Do not insert extra fenced blocks before or between those four blocks. After the four blocks, display the deployment instructions as plain Markdown.

## `package.json` Requirements

- Use a production name derived from the function name, normalized to lowercase letters, numbers, `_`, or `-`.
- Set `"main": "src/index.js"`.
- Set `"engines": { "node": ">=22.0.0" }`.
- Keep `"dependencies": {}` unless the user asked for libraries.
- Do not include placeholder metadata that implies incomplete code.

## Handler Requirements

- Require `crypto`.
- Include the exact `createLog` helper from this file.
- Start each invocation by creating an invocation ID with `crypto.randomUUID()`.
- Log start, validation failures, key simulated decisions, completion, and unhandled errors.
- Missing required fields must return:

```js
return { status: 400, error: "..." };
```

- Unhandled errors must return:

```js
return { status: 500, error: "..." };
```

- Use small helper functions when they make the handler clearer, but avoid unnecessary abstractions.
- Do not start HTTP servers or listeners.
- Do not write files, cache across invocations, or depend on process state for correctness.
- Do not use mock data patterns in production application code. For Genesys Cloud Functions that explicitly simulate an external service, generated sample records are allowed only as the function's requested behavior.

## Input Contract Rules

The input JSONSchema must be flat:

- Top-level `"type": "object"`.
- Only simple top-level `"properties"`.
- No nested objects, sub-objects, arrays, or object-valued input fields.
- Allowed input property types are only `boolean`, `integer`, `null`, `number`, and `string`.
- Property names must match `^[A-Za-z][A-Za-z0-9_-]*$`.
- Required fields should match handler validation.
- Every input property must include a comprehensive `description`.

If the requested input needs arrays or nested objects, ask the user to flatten the input into simple parameters before generating the contract.

## Output Contract Rules

- Top-level `"type": "object"`.
- No `required` properties in the output contract.
- Nested output structures are allowed when they match the requested response.
- Every property defined at every level must include a comprehensive `description`.
- Keep schemas clear enough for Genesys Cloud contract validation and for flow authors to map outputs.

## Deployment Instructions

Always display these instructions after generated function blocks:

1. Ensure you have at least one active Function Data Actions integration; create the new action there.
2. On your laptop, create a folder named with the function name.
3. Put `package.json` in the root and `src/index.js` inside a `src/` folder.
4. Zip `src/` and `package.json` into `function.zip`.
5. In the Function Data Action tab set:
   - Handler: `src/index.handler`
   - Runtime: `nodejs22.x`
   - Timeout: `15 seconds`
   - Upload: `function.zip`
6. In the Contracts tab, paste both JSONSchema contracts and switch to JSON mode.
7. Test. If errors occur, collect the inputs used and the External execution log section.

## Terraform And CRUD Guidance

Treat Terraform with provider source `mypurecloud/genesyscloud` as the desired-state authority when the installed provider supports the needed integration or data action resource.

Before adding or changing provider-specific HCL:

1. Check the pinned provider version and `.terraform.lock.hcl` when present.
2. Inspect the installed provider schema.
3. Review current provider Registry docs for the exact resource, data source, arguments, permissions, and scopes.
4. Confirm how the provider models Function Data Actions, upload or publish behavior, contracts, and timeout settings.

For create:

- Reuse existing integration/action modules and naming conventions first.
- Create or reference the Function Data Actions integration through Terraform when supported.
- Add the function package and contracts in the repository only if the repo already stores function artifacts, or if the user asked to add them.
- Set the function/action timeout to 15 seconds using the verified provider argument. If the provider cannot manage timeout, document the required manual 15 second setting.

For read:

- Prefer repository state, Terraform state, provider data sources, or read-only SDK/CLI/REST checks.
- Do not print secrets or state-sensitive values.

For update:

- Preserve public input names, output fields, action names, and handler path unless the user explicitly requests a breaking change.
- Re-run contract review because contract drift can break Architect flows.
- Keep old and new behavior compatible when the action is already used by flows.
- Set or preserve the 15 second timeout.

For delete:

- Stop and confirm blast radius before removing a function action, integration, contract, or Terraform-managed artifact.
- Identify dependent Architect flows or Data Action references before deletion.
- Prefer removing the Terraform resource and reviewing the plan over direct API deletion.

## Validation And Smoke Tests

For generated code, run or recommend:

```bash
node --check src/index.js
```

For Terraform-managed Functions, also run the applicable Terraform checks from `validation-and-release.md`.

Post-deploy smoke tests should use realistic input values, verify the output contract shape, confirm failures return `status: 400` for missing required fields, and inspect execution logs for `INFO`, `ERROR`, or `FATAL` records without exposing secrets.
