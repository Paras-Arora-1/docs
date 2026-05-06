# argocd module (Aperium)

Bootstraps ArgoCD on a target GKE cluster by creating:
- `argo-cd` namespace
- repository credentials secret using GitHub App auth
- ArgoCD Helm release
- local `argo-resources` Helm release for AppProject and optional app-of-apps sync

Use `github_app_private_key` as a sensitive Terraform Cloud workspace variable.
