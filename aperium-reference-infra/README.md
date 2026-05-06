# Aperium Reference Infra

A trimmed, self-contained reference package for deploying **Aperium on GCP** from shared environment bootstrap through application rollout.

This package was extracted from a production-style Aperium infrastructure layout and kept close to the real deployment shape so a DevOps engineer can use it in two ways:

1. as a **reference snapshot** of what Aperium needs in GCP, ArgoCD, and Helm
2. as a **template-runnable starting point** by filling in placeholders, secrets, and environment-specific values

## What is included

### Shared environment stack
- `envs/aperium-apps-prod/tf`
- `tf/modules/argocd`
- `tf/modules/base_resources`

This layer bootstraps the shared environment:
- VPC, subnet, private service networking, NAT
- GKE Autopilot cluster
- public DNS zone for your apps subdomain, templated as `apps.YOUR_DOMAIN.`
- ArgoCD bootstrap
- controller/service-account plumbing for platform add-ons
- Cloud Armor policies
- Secret Manager container for Terraform agent configuration

### App-specific dependency stack
- `apps/aperium/envs/prod/tf`

This layer bootstraps Aperium-owned dependencies:
- runtime GSA + Workload Identity
- Artifact Registry repo
- GCS bucket
- Secret Manager secret containers
- BigQuery dataset
- optional Cloud SQL, PostgreSQL grants, Redis, and KEDA DB secret generation

### Argo applications and values
- `envs/aperium-apps-prod/argo`
- `envs/aperium-apps-prod/values`

Retained dependency set:
- `cert-manager`
- `external-secrets`
- `external-dns`
- `gke-gateway`
- `gateway-smoke`
- `keda`
- `kyverno`
- `stakater-reloader`
- `terraform-operator`
- `prefect` (minimal server + Aperium worker targeting `aperium-pool`)
- `phoenix`
- `qdrant`
- `aperium` plus in-cluster MCP services
- the current prod-style deployment shape also includes a dedicated background scheduler and cleanup cronjobs for invoice export, file cache, and PostgreSQL tabular cleanup

### Local charts
- `charts/aperium`
- `charts/aperium-mcp-common`
- `charts/cert-manager-resources`
- `charts/gateway-smoke`
- `charts/gke-gateway-api`
- `charts/kyverno-resources`
- `charts/prefect-resources`
- `charts/qdrant-resources`
- `charts/terraform-agent-resources`

## What is intentionally out of scope

This package starts at the **shared environment / cluster bootstrap** layer. It does **not** include:
- GCP org/folder/project creation
- Terraform Cloud OIDC/bootstrap stacks
- CI/CD pipelines that build and publish application images
- application source code
- parent-DNS delegation outside the managed subdomain

Treat those as prerequisites.

## Templating approach

The retained values/defaults and the extracted `charts/aperium` templates now cover the current prod deployment shape more closely, including the dedicated scheduler, cleanup cronjobs, and the newer MCP service variants.


This package now uses placeholders for most environment-specific runtime values, including:
- GCP project IDs
- GAR image paths
- Cloud SQL connection strings
- service account emails
- cluster secret store names
- Terraform Cloud organization / workspace names
- public DNS hosts

Reference snapshots are still preserved in:
- `envs/aperium-apps-prod/tf/vars.reference.tfvars`
- `apps/aperium/envs/prod/tf/vars.reference.tfvars`

For a single list of all placeholders and where they appear, see:
- `PLACEHOLDERS.md`

## First things to change

Before using this package as a live repo, update these values:

1. **Git repo URL placeholder**
   - replace `https://github.com/YOUR_ORG/aperium-reference-infra.git`
   - files already point ArgoCD and bootstrap Terraform at this placeholder

2. **Terraform variables**
   - start from `envs/aperium-apps-prod/tf/vars.auto.tfvars.example`
   - start from `apps/aperium/envs/prod/tf/vars.auto.tfvars.example`
   - compare with `vars.reference.tfvars` in each directory for the extracted reference values

3. **GitHub App credentials for ArgoCD**
   - `github_app_id`
   - `github_app_installation_id`
   - sensitive variable `github_app_private_key`

4. **GCP / TFC / DNS placeholders throughout values files**
   - `YOUR_GCP_PROJECT_ID`
   - `YOUR_GCP_REGION`
   - `YOUR_GCP_ZONE`
   - `YOUR_DOMAIN`
   - `YOUR_CLUSTER_SECRET_STORE_NAME`
   - `YOUR_TFC_ORG`
   - `YOUR_SHARED_ENV_WORKSPACE`
   - `YOUR_APP_WORKSPACE`
   - `YOUR_PREFECT_CLOUDSQL_INSTANCE`

5. **Secret payloads**
   - load the required Secret Manager secrets described in `docs/secret-contract.md`

## Prefect prerequisite checklist

Before syncing the retained `prefect` application, make sure all of these are true:

- [ ] `YOUR_PREFECT_CLOUDSQL_INSTANCE` is set and reachable from the cluster
- [ ] the Prefect runtime GSA exists, e.g. `prefect@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com`
- [ ] `prefect-admin-credentials` exists in the external secret store and produces a Kubernetes secret with `auth-string`
- [ ] `prefect-server` and `prefect-worker-aperium` values have been templated for your environment
- [ ] you have a bootstrap path to create the `aperium-pool` work pool after Prefect server is healthy

See also:
- `docs/deployment-order.md`
- `docs/secret-contract.md`
- `envs/aperium-apps-prod/values/prefect-server.yaml`
- `envs/aperium-apps-prod/values/prefect-worker-aperium.yaml`

## Deployment order

The current prod-style deployment shape documented in this package includes these additional MCP variants beyond the earlier retained baseline:
- `aperium-mcp-slack-workspace`
- `aperium-mcp-atlassian`
- `aperium-mcp-gcs-datalake`

It also documents the dedicated scheduler and cleanup-job shape now used in production.


Use this package in the following order:

1. bootstrap the shared environment with `envs/aperium-apps-prod/tf`
2. delegate DNS and verify ArgoCD bootstrap
3. load required Secret Manager payloads
4. let ArgoCD sync platform prerequisites
5. apply `apps/aperium/envs/prod/tf`
6. sync and bootstrap `prefect`, then create `aperium-pool`
7. verify `qdrant`, `phoenix`, and `prefect`
8. sync `aperium` and its MCP services
9. verify end-to-end readiness

Detailed instructions live in:
- `docs/deployment-order.md`
- `docs/dependency-contract.md`
- `docs/secret-contract.md`

## Important package conventions

- `vars.reference.tfvars` files are **reference snapshots**, not auto-loaded Terraform inputs
- `vars.auto.tfvars.example` files are the starting point for real usage
- local Argo app manifests are wired to this extracted package, not back to the original source repo
- the real deployment structure is preserved, but many live prod-specific values have been replaced with placeholders

## Quick validation commands

```bash
terraform fmt -check -recursive .
rg -n "YOUR_ORG/aperium-reference-infra|vars.reference.tfvars|YOUR_GCP_PROJECT_ID|YOUR_DOMAIN" .
find envs/aperium-apps-prod/argo -maxdepth 1 -type f | sort
```
