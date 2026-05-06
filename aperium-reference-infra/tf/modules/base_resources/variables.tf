variable "gcp_project_id" {
  description = "Project ID for shared environment resources."
  type        = string
}

variable "gcp_region" {
  description = "Primary region for shared environment resources."
  type        = string
  default     = "us-central1"
}

variable "env_name" {
  description = "Environment name used in shared resource names (network/cluster)."
  type        = string
  default     = "prod"
}

variable "network_cidr" {
  description = "Primary subnet CIDR for the environment VPC."
  type        = string
}

variable "service_cidr" {
  description = "Secondary CIDR range for Kubernetes services."
  type        = string
}

variable "pod_cidr" {
  description = "Secondary CIDR range for Kubernetes pods."
  type        = string
}

variable "nat_ip_count" {
  description = "Number of static egress IPs to allocate for Cloud NAT."
  type        = number
  default     = 1
}
