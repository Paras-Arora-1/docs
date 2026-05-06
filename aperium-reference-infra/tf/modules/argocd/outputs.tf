output "namespace" {
  description = "Namespace where ArgoCD is installed."
  value       = kubernetes_namespace_v1.argo_cd.metadata[0].name
}

output "server_hostname" {
  description = "Expected ArgoCD hostname."
  value       = "argo-cd.${trim(var.dns_domain, ".")}"
}
