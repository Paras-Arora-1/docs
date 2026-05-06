# 2026-04-17 Infrastructure Release Notes

## Summary

This release brings Hillspire `gcp-infra` Aperium environment overlays beyond the current retained baseline documented in `aperium-reference-infra`.

Compared with the current state of `~/hillspire/aperium-reference-infra`:
- staging and prod now run the same Aperium rollout image tag: `sha-20cafa1`
- staging and prod now include the dedicated background scheduler pattern instead of relying on backend scheduler execution alone
- staging and prod now include cleanup cronjobs for invoice export, file cache, and PostgreSQL tabular cleanup
- staging and prod now include additional MCP services beyond the current retained reference list:
  - `aperium-mcp-slack-workspace`
  - `aperium-mcp-atlassian`
  - `aperium-mcp-gcs-datalake`
- prod was brought to the same service shape as staging/sandbox for these capabilities

## Reference baseline used for comparison

The current retained reference repo state is:
- `charts/aperium/values.yaml`
  - `scheduler` is not modeled
  - cleanup cronjobs are not modeled
  - worker metrics default to disabled
- `docs/deployment-order.md`
  - current retained MCP values files stop at:
    - `aperium-mcp-google-workspace.yaml`
  - current documented core `aperium.yaml` MCP URLs include:
    - `aperium-mcp-common`
    - `aperium-mcp-odoo`
    - `aperium-mcp-google-workspace`
    - `qdrant.qdrant.svc.cluster.local`
- `docs/secret-contract.md`
  - backend runtime settings continue to come from the `aperium-backend-yml` env payload
  - MCP auth continues to come from `aperium-mcp-auth-token`

That means several features now present in `gcp-infra` env overlays are ahead of what the retained reference repo currently documents.

## Git-managed environment overlay changes

### Staging

Staging was updated to add the missing parity services and runtime shape:
- added Argo sources for:
  - `aperium-mcp-slack-workspace`
  - `aperium-mcp-atlassian`
  - `aperium-mcp-gcs-datalake`
- added values files for:
  - `envs/hillspire-apps-stg/values/aperium-mcp-slack-workspace.yaml`
  - `envs/hillspire-apps-stg/values/aperium-mcp-atlassian.yaml`
  - `envs/hillspire-apps-stg/values/aperium-mcp-gcs-datalake.yaml`
- updated `envs/hillspire-apps-stg/values/aperium.yaml` to:
  - disable backend scheduler execution when the dedicated scheduler is enabled
  - add MCP routing entries for `slack_workspace`, `atlassian`, and `gcs_datalake`
  - enable cleanup runner modes
  - enable the dedicated `scheduler:` block
  - enable:
    - `invoiceExportCleanup`
    - `fileCacheCleanup`
    - `postgresqlTabularCleanup`
- corrected staging MCP image-tag drift so all staging Aperium services converge on `sha-20cafa1`

### Prod

Prod was then brought to the same feature shape:
- added Argo sources for:
  - `aperium-mcp-slack-workspace`
  - `aperium-mcp-atlassian`
- added values files for:
  - `envs/hillspire-apps-prod/values/aperium-mcp-slack-workspace.yaml`
  - `envs/hillspire-apps-prod/values/aperium-mcp-atlassian.yaml`
- updated `envs/hillspire-apps-prod/values/aperium.yaml` to:
  - disable backend scheduler execution when the dedicated scheduler is enabled
  - add MCP routing entries for `slack_workspace` and `atlassian`
  - keep `gcs_datalake` routing enabled
  - enable cleanup runner modes
  - enable the dedicated `scheduler:` block
  - enable:
    - `invoiceExportCleanup`
    - `fileCacheCleanup`
    - `postgresqlTabularCleanup`
  - enable `worker.metrics.serviceMonitor`
- updated all prod Aperium values files to use the same rollout image tag:
  - `sha-20cafa1`

### Image tags

Current Git-managed overlay state after the rollout:
- staging Aperium values files: `sha-20cafa1`
- prod Aperium values files: `sha-20cafa1`

## Environment variables changed

The following backend/application env-file settings were changed as part of this rollout and should be considered part of the release notes:

- `GALLERY_ENABLED=true`
- `TOOL_LOADING_CAPABILITY_ROUTING_ENABLED=true`
- `TOOL_LOADING_CAPABILITY_ROUTING_SHADOW_MODE=false`
- `ENABLE_PARALLEL_TOOL_EXECUTION=false`
- `ENABLE_FORK_MODEL=false`
- `DASHBOARD_V2_ENABLED=false`

Aperium language-model provider profile settings should also be called out in the changelog whenever they are introduced or changed alongside a rollout, because they materially affect runtime model selection even though they are not modeled in this reference chart package:

- `DEFAULT_LLM_PROVIDER`
- `PRIMARY_LLM_PROVIDER`
- `PRIMARY_LLM_MODEL`
- `SECONDARY_LIGHTWEIGHT_LLM_PROVIDER`
- `SECONDARY_LIGHTWEIGHT_LLM_MODEL`
- `ENABLE_LLM_FALLBACK`

Operationally in Aperium:
- `PRIMARY_LLM_PROVIDER` / `PRIMARY_LLM_MODEL` define the canonical primary language-model profile
- `SECONDARY_LIGHTWEIGHT_LLM_PROVIDER` / `SECONDARY_LIGHTWEIGHT_LLM_MODEL` define the canonical lightweight secondary profile
- if a requested provider is unset or not actually configured, Aperium resolves back to an available configured provider at runtime
- these settings should be treated the same way as the flags above: runtime env-file settings delivered through `aperium-backend-yml`, not Git-managed Helm chart defaults in this repo

## Important note about env-var provenance

These six variables, plus the language-model provider profile settings listed above, are **not currently modeled in the retained reference repo**:
- they do not appear in `charts/aperium/values.yaml`
- they do not appear in `docs/deployment-order.md`
- they do not appear in `docs/secret-contract.md`
- they do not appear in the current `gcp-infra` Aperium overlay YAML checked during this release

Based on the current reference repo contract, these settings belong to the `aperium-backend-yml` env payload rather than the Git-managed Helm values layer.

So, relative to `aperium-reference-infra`, these env-var changes should be understood as **runtime env-file changes accompanying the infrastructure rollout**, not chart-default changes captured in the retained package repo.

## Overlay env variables changed in Git

The Git-managed overlay env changes that *are* represented directly in `gcp-infra` include:

### Scheduler split
- backend:
  - `AGENT_INTELLIGENCE_SCHEDULER_ENABLED=false`
- dedicated scheduler deployment:
  - `AGENT_INTELLIGENCE_SCHEDULER_ENABLED=true`

### Cleanup runner modes
- `INVOICE_EXPORT_CLEANUP_RUNNER_MODE=cronjob`
- `FILE_CACHE_CLEANUP_RUNNER_MODE=cronjob`
- `TABULAR_POSTGRESQL_CLEANUP_RUNNER_MODE=cronjob`

### Added MCP routing entries
Backend and scheduler overlay env now include routing for:
- `slack_workspace`
- `atlassian`
- `gcs_datalake`

Concretely, the overlay now includes `MCP_SERVER_TRANSPORT_*`, `MCP_SERVER_URL_*`, and `MCP_SERVER_TIMEOUT_*` entries for:
- `slack_workspace`
- `atlassian`
- `gcs_datalake`

## Explicit non-change

Per rollout direction, this release did **not** add:
- `BIGQUERY_MCP_JOB_PROJECT`

to the prod Aperium overlay.

## Documentation drift versus reference repo

The retained `aperium-reference-infra` docs are now behind the deployed environment shape in these ways:
- no documented scheduler section in chart defaults
- no documented cleanup cronjob sections in chart defaults
- no retained reference mention of:
  - `aperium-mcp-slack-workspace`
  - `aperium-mcp-atlassian`
  - `aperium-mcp-gcs-datalake`
- no reference documentation for the runtime env-file flags listed above
- no reference documentation for the primary/secondary language-model provider profile env settings used by Aperium

## Recommended follow-up for the reference repo

Update `aperium-reference-infra` to document the now-current operational shape:
- add scheduler support to the retained chart/docs narrative
- add cleanup cronjob support to the retained chart/docs narrative
- update the retained MCP service list in `docs/deployment-order.md`
- document which runtime flags are expected in `aperium-backend-yml` even if they remain outside Helm values
- document the Aperium primary/secondary language-model provider profile env contract (`DEFAULT_LLM_PROVIDER`, `PRIMARY_LLM_PROVIDER`, `PRIMARY_LLM_MODEL`, `SECONDARY_LIGHTWEIGHT_LLM_PROVIDER`, `SECONDARY_LIGHTWEIGHT_LLM_MODEL`, `ENABLE_LLM_FALLBACK`)
