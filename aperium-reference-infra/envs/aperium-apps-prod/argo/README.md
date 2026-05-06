# aperium-apps-prod Argo applications

ArgoCD application manifests retained for the extracted Aperium dependency package.

This directory is watched by the Argo app-of-apps bootstrap defined in:
- `envs/aperium-apps-prod/tf/argo-resources.yaml`

## Retained applications

### Platform prerequisites
- `cert-manager`
- `external-secrets`
- `external-dns`
- `gke-gateway`
- `gateway-smoke`
- `keda`
- `kyverno`
- `stakater-reloader`
- `terraform-operator`

### Aperium dependency services
- `prefect` (minimal server + `prefect-worker-aperium`)
- `phoenix`
- `qdrant`
- `aperium` (core app plus retained MCP service sources)

## Notes

- All package-local repo references have been rewritten to the placeholder repo URL `https://github.com/YOUR_ORG/aperium-reference-infra.git`.
- Replace that placeholder before using the manifests in a live ArgoCD environment.
- `odoo` and `odoo-internal` were intentionally excluded from this extracted package because the requested scope was Aperium plus its retained dependency set, not the full shared prod environment.
- The `aperium` application still deploys several MCP variants so operators can see the full reference connector shape.
- The retained `prefect` application is intentionally minimal: Prefect server, `prefect-worker-aperium`, and the local `prefect-resources` chart. The `aperium-pool` work pool must still be created during bootstrap.
