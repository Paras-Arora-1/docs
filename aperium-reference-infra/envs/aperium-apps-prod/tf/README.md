# aperium-apps-prod shared env reference

Manages the shared GCP environment resources required before deploying Aperium.

Workspace: `YOUR_TFC_ORG/YOUR_SHARED_ENV_WORKSPACE`
Working directory: `envs/aperium-apps-prod/tf`

## Shared resources in this stack

- VPC network + subnetwork + secondary ranges
- Cloud Router + Cloud NAT static egress IP(s)
- Private Service Networking connection
- GKE Autopilot cluster
- Public Cloud DNS zone(s)
- Platform GSAs + Workload Identity bindings for cert-manager / external-dns / external-secrets
- Cloud Armor allowlist policies for Aperium Gateway traffic
- Shared Secret Manager container for Terraform agent token (`tfc-agent-config`)
- Artifact Registry reader grant for the default GKE node service account
- ArgoCD bootstrap (GitHub App auth)

## Variable files in this extracted package

- `vars.auto.tfvars.example` — starting point for real use
- `vars.reference.tfvars` — extracted reference values, kept for operator context but not auto-loaded

## Run

```bash
terraform init
terraform plan
terraform apply
```

After apply:
- use `delegation_ns_records` output to delegate DNS from the parent provider
- use `network_self_link` and `gke_cluster_name` outputs for the app-specific stack
- load the required secret payloads described in `../../../docs/secret-contract.md`

## ArgoCD bootstrap notes

Before apply:
- replace the placeholder repo URL in Terraform and Argo manifests
- set `github_app_id` and `github_app_installation_id`
- set `github_app_private_key` as a sensitive Terraform variable
- replace remaining placeholders such as `YOUR_GCP_PROJECT_ID`, `YOUR_DOMAIN`, and `YOUR_CLUSTER_SECRET_STORE_NAME`

`argoSync` points to `envs/aperium-apps-prod/argo` inside this extracted package.
