# Dependency Contract

This file defines the dependency boundary retained in this extracted package.

## Scope

The package covers the infrastructure and ArgoCD dependency chain needed to bring Aperium from a shared GCP environment bootstrap to a functioning application deployment.

## Dependency groups

### 1. Shared platform prerequisites

These are required before the app layer can reconcile correctly:
- `cert-manager`
- `external-secrets`
- `external-dns`
- `gke-gateway`
- `gateway-smoke`
- `keda`
- `kyverno`
- `stakater-reloader`
- `terraform-operator`

### 2. Direct in-cluster runtime dependencies

These are the services the current prod-style Aperium deployment calls inside the cluster:
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

These references are visible in the prod-style `aperium.yaml` overlay carried forward from the live deployment shape.

### 3. Retained supporting services

These are included because they are part of the reference Aperium deployment shape or surrounding operational stack:
- `prefect` (minimal server + `prefect-worker-aperium` targeting `aperium-pool`)
- `phoenix`
- a dedicated `background-scheduler` deployment when scheduler mode is enabled
- cleanup cronjobs for:
  - invoice export cleanup
  - file cache cleanup
  - PostgreSQL tabular cleanup

## Cross-stack ordering contract

### Shared env stack must exist first
Apply `envs/aperium-apps-prod/tf` before anything else in this package.

It produces the infrastructure that later steps need:
- network and subnetwork
- GKE cluster
- DNS zone
- ArgoCD bootstrap
- platform Workload Identity GSAs
- Terraform agent config secret container

### App stack depends on shared env outputs
Apply `apps/aperium/envs/prod/tf` only after the shared env stack exists.

It depends on values such as:
- `gcp_project_id`
- `gcp_network_path`
- cluster reachability assumptions for private resources

### Prefect scaffold assumptions
The retained Prefect deployment is intentionally minimal and assumes the following are already available or will be adapted for your environment:
- a Prefect backing Cloud SQL instance
- a Prefect runtime GSA (for example `prefect@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com`)
- a secret-store entry named `prefect-admin-credentials`
- a bootstrap step to create the `aperium-pool` work pool after Prefect server is up

## Go / no-go gates

## Go
Proceed to full Aperium rollout only when all are true:
1. shared env Terraform has applied successfully
2. DNS delegation is complete
3. ArgoCD is reconciling the retained app-of-apps set
4. `external-secrets` is healthy and the `ClusterSecretStore` is Ready
5. `prefect` is healthy and `aperium-pool` exists
6. `qdrant` is healthy and API keys are synced
7. `phoenix` is healthy and auth secrets are synced
8. app-specific Terraform dependencies are created
9. required Secret Manager payloads exist

## No-go
Stop and remediate if any of these are true:
- ArgoCD cannot read the repo because the repo URL placeholder or GitHub App credentials were not updated
- Secret Manager containers exist but payloads were never added
- `external-secrets` is unhealthy or cannot access GCP Secret Manager
- `prefect-admin-credentials` is missing or malformed
- `aperium-pool` was never created in Prefect
- `qdrant-api-keys` is missing in either `qdrant` or `aperium` namespace
- Cloud SQL or Redis is expected but disabled in the app stack
- the app stack is running from a workspace/agent that cannot reach private database endpoints
