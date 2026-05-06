# Placeholder Guide

This package is intentionally templated. Before using it for a live deployment, replace the placeholders below with environment-specific values.

## Repo placeholder

| Placeholder | Meaning | Typical value | Primary locations |
| --- | --- | --- | --- |
| `YOUR_ORG` | GitHub org or owner for this extracted repo | `acme` | Argo app manifests, bootstrap Terraform repo URL, docs |

Used as part of:
- `https://github.com/YOUR_ORG/aperium-reference-infra.git`

## GCP placeholders

| Placeholder | Meaning | Typical value | Primary locations |
| --- | --- | --- | --- |
| `YOUR_GCP_PROJECT_ID` | GCP project hosting the shared apps environment | `my-apps-prod` | Terraform examples, Helm values, External Secrets, GAR paths, Cloud SQL connection strings |
| `YOUR_GCP_REGION` | Primary GCP region | `us-central1` | Terraform examples, GAR paths, Cloud SQL connection strings, External Secrets cluster location |
| `YOUR_GCP_ZONE` | Default Terraform/provider zone | `us-central1-a` | shared env Terraform example |
| `YOUR_GKE_CLUSTER_NAME` | GKE cluster name used by Workload Identity-backed secret store config | `prod` | `envs/aperium-apps-prod/values/external-secrets.yaml` |
| `YOUR_NETWORK_NAME` | Shared VPC network name | `prod` | app Terraform example `gcp_network_path` |
| `YOUR_CLOUDSQL_INSTANCE` | Cloud SQL instance name for the app and retained MCP services | `aperium-abc123` | `aperium.yaml`, MCP values files |
| `YOUR_PREFECT_CLOUDSQL_INSTANCE` | Cloud SQL instance name used by Prefect server | `prefect-abc123` | `prefect-server.yaml` |
| `YOUR_SHARING_BUCKET_NAME` | GCS bucket name used by app sharing/storage settings | `my-apps-prod-sharing` | app Terraform example, `aperium.yaml` |

## DNS / host placeholders

| Placeholder | Meaning | Typical value | Primary locations |
| --- | --- | --- | --- |
| `YOUR_DOMAIN` | Base delegated domain suffix for app hostnames | `example.com` | DNS zone example, external-dns values, cert-manager email example, Gateway hosts |

This drives hostnames like:
- `apps.YOUR_DOMAIN`
- `www.apps.YOUR_DOMAIN`
- `gateway-smoke.apps.YOUR_DOMAIN`

## Kubernetes / secrets placeholders

| Placeholder | Meaning | Typical value | Primary locations |
| --- | --- | --- | --- |
| `YOUR_CLUSTER_SECRET_STORE_NAME` | `ClusterSecretStore` name used by External Secrets | `my-apps-prod-secrets` | `external-secrets.yaml`, `gke-gateway.yaml`, `qdrant-resources.yaml`, `aperium.yaml`, MCP values |

## Terraform Cloud / HCP Terraform placeholders

| Placeholder | Meaning | Typical value | Primary locations |
| --- | --- | --- | --- |
| `YOUR_TFC_ORG` | Terraform Cloud organization | `acme-platform` | shared env/app Terraform `main.tf`, Terraform agent values |
| `YOUR_SHARED_ENV_WORKSPACE` | shared environment workspace name | `my-apps-prod` | `envs/aperium-apps-prod/tf/main.tf` |
| `YOUR_APP_WORKSPACE` | app-specific dependency workspace name | `aperium-prod` | `apps/aperium/envs/prod/tf/main.tf` |
| `YOUR_TFC_AGENT_POOL_NAME` | Terraform agent pool name for private-network runs | `aperium-prod` | Terraform operator / agent values |

## GitHub App placeholders

| Placeholder | Meaning | Typical value | Primary locations |
| --- | --- | --- | --- |
| `YOUR_GITHUB_APP_ID` | GitHub App ID used by ArgoCD repo credentials | `123456` | shared env Terraform example |
| `YOUR_GITHUB_APP_INSTALLATION_ID` | installation ID for the repo installation | `987654321` | shared env Terraform example |

## Suggested replacement order

1. Replace repo URL placeholder (`YOUR_ORG`)
2. Fill both Terraform example files:
   - `envs/aperium-apps-prod/tf/vars.auto.tfvars.example`
   - `apps/aperium/envs/prod/tf/vars.auto.tfvars.example`
3. Replace GCP/TFC placeholders in Helm values files
4. Load Secret Manager payloads described in `docs/secret-contract.md`
5. Compare against `vars.reference.tfvars` files if you need the original extracted reference values

## Quick search commands

Find remaining placeholders:

```bash
rg -n 'YOUR_[A-Z0-9_]+' .
```

Inspect the original extracted reference values:

```bash
readlink -f envs/aperium-apps-prod/tf/vars.reference.tfvars
readlink -f apps/aperium/envs/prod/tf/vars.reference.tfvars
```
