# base_resources module (Aperium)

Minimal shared environment module for:
- VPC network + subnet + secondary ranges
- Cloud Router + Cloud NAT
- Private Service Networking connection
- GKE Autopilot cluster
- Core APIs needed by those resources
- Platform GSAs + Workload Identity bindings for:
  - external-dns
  - cert-manager
  - external-secrets

This is intentionally smaller than Hillspire's full base resources module and is meant as an initial scaffold.
