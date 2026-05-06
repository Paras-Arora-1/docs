# Deployment Order

This guide describes the recommended rollout path from a new shared GCP environment to a full Aperium deployment.

## Phase 0: Prerequisites

Have these in place before applying this package:
- a GCP project for the shared apps environment
- Terraform Cloud/HCP Terraform organization and workspaces
- credentials to run Terraform against GCP
- a Git repository that contains this extracted package
- a GitHub App that ArgoCD can use for repository access
- authority to delegate the parent DNS zone to the managed subdomain returned by Terraform

## Phase 1: Prepare the package repo

1. Replace the placeholder repo URL `https://github.com/YOUR_ORG/aperium-reference-infra.git`
2. Copy and edit:
   - `envs/aperium-apps-prod/tf/vars.auto.tfvars.example`
   - `apps/aperium/envs/prod/tf/vars.auto.tfvars.example`
3. Replace the remaining placeholders used in values and Terraform files, such as:
   - `YOUR_GCP_PROJECT_ID`
   - `YOUR_GCP_REGION`
   - `YOUR_DOMAIN`
   - `YOUR_CLUSTER_SECRET_STORE_NAME`
   - `YOUR_TFC_ORG`
4. Use `vars.reference.tfvars` in each directory only as a reference baseline
5. Set `github_app_private_key` as a sensitive Terraform variable in the shared env workspace

## Phase 2: Bootstrap the shared environment

Apply:
- `envs/aperium-apps-prod/tf`

This creates the shared network and cluster substrate plus ArgoCD bootstrap dependencies.

Expected outputs include:
- DNS delegation NS records
- GKE cluster name
- network self link
- NAT IPs
- Cloud Armor policy names
- `tfc-agent-config` secret container

## Phase 3: Delegate DNS

Use the `delegation_ns_records` output from the shared env stack to delegate the managed subdomain from the parent DNS provider.

Without this, public hostnames such as `www.apps.YOUR_DOMAIN` will not resolve correctly.

## Phase 4: Seed required Secret Manager payloads

Load the secret payloads described in `docs/secret-contract.md`.

Important sequence notes:
- the shared env stack creates the `tfc-agent-config` secret container, but you still need to add the `team_token` payload
- `external-secrets` cannot materialize Kubernetes secrets until the backing GCP Secret Manager payloads exist
- `prefect-admin-credentials` should exist before syncing the retained Prefect app
- `phoenix-auth` and `qdrant-api-keys` should exist before validating those services
- `aperium-backend-yml` and `aperium-mcp-auth-token` must exist before the Aperium stack becomes healthy

## Phase 5: Wait for Argo platform prerequisites

ArgoCD should reconcile these foundational apps:
- `cert-manager`
- `external-secrets`
- `external-dns`
- `gke-gateway`
- `gateway-smoke`
- `keda`
- `kyverno`
- `stakater-reloader`
- `terraform-operator`

Recommended checks:
- Argo applications are Healthy/Synced
- `ClusterSecretStore` exists and is Ready
- gateway namespace and public gateway exist
- DNS controller is reconciling records

## Phase 6: Apply Aperium app-specific Terraform

Apply:
- `apps/aperium/envs/prod/tf`

This stack creates the app-owned dependency layer.

### Minimum commonly-needed resources
- runtime GSA and Workload Identity bindings
- Artifact Registry repo
- GCS bucket
- Secret Manager secret containers
- BigQuery dataset

### Optional but usually needed for full deployment
- Cloud SQL
- PostgreSQL grants
- Redis
- generated KEDA DB secret version

If you enable the PostgreSQL-provider-backed resources, run this workspace from a private-network-reachable Terraform agent pool.

## Phase 7: Sync Prefect and create `aperium-pool`

The retained Prefect app is intentionally minimal. It includes:
- `prefect-server`
- `prefect-worker-aperium`
- local `prefect-resources`

Before syncing it, make sure you have adapted or provided:
- a Prefect backing Cloud SQL instance (`YOUR_PREFECT_CLOUDSQL_INSTANCE`)
- a Prefect runtime GSA such as `prefect@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com`
- the `prefect-admin-credentials` secret in your external secret store

Recommended bootstrap runbook:

```bash
kubectl -n prefect port-forward svc/prefect-server 4200:4200
export PREFECT_API_URL=http://127.0.0.1:4200/api
prefect work-pool create aperium-pool --type kubernetes
prefect work-pool ls
```

Alternative: create the pool in the Prefect UI after port-forwarding to the server.

Proceed only when:
- Prefect server is healthy
- `prefect-worker-aperium` is healthy
- `aperium-pool` exists

## Phase 8: Validate supporting runtime services

Before enabling or debugging the core app, verify:
- `prefect` is healthy and `aperium-pool` exists
- `qdrant` is healthy and has API key secrets
- `phoenix` is healthy and has auth secrets

These are retained because they are part of the operational dependency set around Aperium, even though only some of them are directly called by the main app at runtime.

## Phase 9: Roll out Aperium and MCP services

The `aperium` Argo application deploys:
- core Aperium frontend/backend/worker/migrations
- a dedicated background scheduler when enabled in values
- cleanup cronjobs for invoice export, file cache, and PostgreSQL tabular cleanup when enabled in values
- in-cluster MCP services built from `charts/aperium-mcp-common`

Current retained MCP values files include:
- `aperium-mcp-common.yaml`
- `aperium-mcp-prefect.yaml`
- `aperium-mcp-salesforce.yaml`
- `aperium-mcp-malbek.yaml`
- `aperium-mcp-arena.yaml`
- `aperium-mcp-netsuite.yaml`
- `aperium-mcp-odoo.yaml`
- `aperium-mcp-google-workspace.yaml`
- `aperium-mcp-slack-workspace.yaml`
- `aperium-mcp-atlassian.yaml`
- `aperium-mcp-epic.yaml`
- `aperium-mcp-gcs-datalake.yaml`

The current prod-style `aperium.yaml` directly references in-cluster URLs for:
- `aperium-mcp-common`
- `aperium-mcp-salesforce`
- `aperium-mcp-malbek`
- `aperium-mcp-netsuite`
- `aperium-mcp-odoo`
- `aperium-mcp-arena`
- `aperium-mcp-prefect`
- `aperium-mcp-google-workspace`
- `aperium-mcp-slack-workspace`
- `aperium-mcp-atlassian`
- `aperium-mcp-epic`
- `aperium-mcp-gcs-datalake`
- `aperium-retrieval`

## Phase 10: Final verification

At minimum verify:
- Argo apps are Healthy/Synced
- `prefect-server` and `prefect-worker-aperium` pods are healthy
- `aperium-pool` exists in Prefect
- `qdrant` service responds and secrets are mounted
- `phoenix` pods are healthy and `phoenix-secret` exists
- `aperium` backend/worker/frontend pods are Ready
- background scheduler and enabled cleanup cronjobs are healthy if those features are turned on
- ExternalSecret-generated Kubernetes secrets exist in expected namespaces
- public routes resolve after DNS propagation
- BigQuery/GCS/Cloud SQL access works from the workload identity
