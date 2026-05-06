# aperium-apps-prod values

Environment-specific Helm values retained for the extracted Aperium dependency package.

## Included value files

### Platform prerequisites
- `cert-manager.yaml`
- `cert-manager-resources.yaml`
- `external-secrets.yaml`
- `external-dns.yaml`
- `gke-gateway.yaml`
- `gateway-smoke.yaml`
- `keda.yaml`
- `kyverno.yaml`
- `stakater.yaml`
- `tfc-agents.yaml`

### Prefect
- `prefect-server.yaml`
- `prefect-worker-aperium.yaml`
- `prefect-resources.yaml`

### Aperium and retained supporting services
- `aperium.yaml`
- `aperium-mcp-common.yaml`
- `aperium-mcp-prefect.yaml`
- `aperium-mcp-salesforce.yaml`
- `aperium-mcp-malbek.yaml`
- `aperium-mcp-arena.yaml`
- `aperium-mcp-netsuite.yaml`
- `aperium-mcp-odoo.yaml`
- `aperium-mcp-google-workspace.yaml`
- `phoenix.yaml`
- `qdrant.yaml`
- `qdrant-resources.yaml`

## Notes

- The files preserve the production-style deployment structure while using placeholders for environment-specific values.
- Use the docs in `../../../docs/` and the Terraform `vars.reference.tfvars` files to decide what to keep exact versus what to templatize for your environment.
- Odoo-related values files were intentionally not carried into this package.
- Prefect values are intentionally minimal and rely on a runbook step to create `aperium-pool` after the server is up.
