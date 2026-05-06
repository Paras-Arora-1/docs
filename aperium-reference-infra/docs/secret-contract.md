# Secret Contract

This package separates **secret container creation** from **secret payload population**.

Terraform typically creates the Secret Manager secret containers. Operators must still add the payloads unless the stack explicitly creates a secret version.

## Required secrets

| Secret Manager secret | Created by | Synced into Kubernetes by | Required keys / payload | Used by |
| --- | --- | --- | --- | --- |
| `tfc-agent-config` | `envs/aperium-apps-prod/tf` | `charts/terraform-agent-resources` via `terraform-operator` | `team_token` | HCP Terraform agent pool |
| `phoenix-auth` | external prerequisite or manual creation | `envs/aperium-apps-prod/values/external-secrets.yaml` | `PHOENIX_SECRET`, `PHOENIX_ADMIN_SECRET`, `PHOENIX_POSTGRES_PASSWORD`, `PHOENIX_SMTP_PASSWORD`, `PHOENIX_DEFAULT_ADMIN_INITIAL_PASSWORD` | Phoenix |
| `prefect-admin-credentials` | external prerequisite or manual creation | `charts/prefect-resources` via `envs/aperium-apps-prod/values/prefect-resources.yaml` | extracted object containing at least `auth-string` | Prefect server + Prefect worker basic auth |
| `aperium-backend-yml` | `apps/aperium/envs/prod/tf` | `charts/aperium` and MCP values via `external-secrets` | `env` payload containing the backend env file contents | Aperium backend, workers, migrations, MCP services |
| `aperium-mcp-auth-token` | `apps/aperium/envs/prod/tf` | `charts/aperium-mcp-common` | `mcp_auth_token` | all retained MCP services |
| `qdrant-api-keys` | `apps/aperium/envs/prod/tf` | `charts/qdrant-resources` and `charts/aperium` | `apiKey`, `readOnlyApiKey` | Qdrant and Aperium |
| `aperium-keda-db-url` | `apps/aperium/envs/prod/tf` when Cloud SQL + secret manager are enabled | `charts/aperium` | `DATABASE_URL` payload | KEDA document worker scaler |

## Notes by secret

### `tfc-agent-config`
- the shared env Terraform creates the secret container only
- you must load the `team_token` payload yourself
- the Terraform operator stack materializes it as a Kubernetes secret for the agent pool

### `phoenix-auth`
- this package retains the ExternalSecret mapping in `envs/aperium-apps-prod/values/external-secrets.yaml`
- the Secret Manager secret must already exist with the expected properties

### `prefect-admin-credentials`
- the local `charts/prefect-resources` chart creates an `ExternalSecret` named `prefect-admin-credentials`
- the backing secret store entry must be extractable into a Kubernetes secret that contains at least the key `auth-string`
- the minimal Prefect deployment in this package assumes this secret exists before Prefect server/worker become healthy

### `aperium-backend-yml`
- this is the most important application secret
- it is treated as an env-file payload, not as many separate key/value secrets
- at minimum it needs the database/application settings required by the backend and the retained MCP services
- it is also the expected home for runtime feature flags and service-routing settings that are not modeled directly as Helm chart defaults in this reference package
- current production-style examples include runtime flags such as:
  - `GALLERY_ENABLED`
  - `TOOL_LOADING_CAPABILITY_ROUTING_ENABLED`
  - `TOOL_LOADING_CAPABILITY_ROUTING_SHADOW_MODE`
  - `ENABLE_PARALLEL_TOOL_EXECUTION`
  - `ENABLE_FORK_MODEL`
  - `DASHBOARD_V2_ENABLED`
- current production-style examples also rely on env-file-provided application settings used alongside the Git-managed overlay, including MCP/retrieval settings for services such as:
  - `aperium-mcp-slack-workspace`
  - `aperium-mcp-atlassian`
  - `aperium-mcp-gcs-datalake`
  - `aperium-retrieval`
- treat these as runtime env-file settings that accompany the deployment shape; they are not a claim that the extracted Helm chart alone expresses every runtime flag used in production

### `aperium-mcp-auth-token`
- a single token is reused across the retained MCP services
- each MCP deployment maps it into a namespaced Kubernetes secret

### `qdrant-api-keys`
- the remote secret uses camelCase properties:
  - `apiKey`
  - `readOnlyApiKey`
- the Kubernetes secrets rendered by External Secrets use kebab-case keys:
  - `api-key`
  - `read-only-api-key`

### `aperium-keda-db-url`
- this is the one retained secret where Terraform can also create the secret **version** automatically
- it is only written when Cloud SQL and Secret Manager support are enabled in the app stack

## Operational checklist

Before expecting the workloads to become healthy, verify:
- each required Secret Manager secret exists
- each required property exists inside the secret payload
- `ClusterSecretStore` points at the correct GCP project
- ExternalSecret resources are Healthy
- the generated Kubernetes secrets exist in the expected namespaces (`aperium`, `prefect`, `qdrant`, `phoenix`, `tfc-operator-system` as applicable)
