# aperium app (prod reference)

Manages the app-specific dependency layer for Aperium.

Workspace: `YOUR_TFC_ORG/YOUR_APP_WORKSPACE`
Working directory: `apps/aperium/envs/prod/tf`

This stack assumes the shared env stack in `envs/aperium-apps-prod/tf` already exists.

## Scaffolded resources

Enabled by default in the example file:
- Artifact Registry repo (`aperium`)
- Runtime GSA + Workload Identity binding + core IAM roles
- GCS app bucket
- Secret Manager secret containers
- BigQuery dataset (`aperium_tabular`) + IAM

Optional features retained in the stack:
- Cloud SQL
- PostgreSQL grants
- Redis
- KEDA DB connection secret generation

## Variable files in this extracted package

- `vars.auto.tfvars.example` — safe starting point
- `vars.reference.tfvars` — extracted reference settings showing a fuller deployment shape

## Cloud SQL + PostgreSQL provider note

If `enable_cloudsql` and `enable_postgresql_grants` are enabled, run this workspace from a private-network-reachable Terraform agent pool. The retained `terraform-operator` and `tfc-agent-config` secret contract exist to support that model.

## Run

```bash
terraform init
terraform plan
terraform apply
```

Use the outputs from the shared env stack for values such as `gcp_network_path`.
Consult `../../../../../docs/secret-contract.md` before expecting the workloads to become healthy.
