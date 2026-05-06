variable "gcp_project_id" {
  description = "Target GCP project for app-specific resources."
  type        = string
}

variable "gcp_region" {
  description = "Primary GCP region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "Default GCP zone for provider context."
  type        = string
  default     = "us-central1-c"
}

variable "gcp_network_path" {
  description = "Full self-link path to the shared VPC network used by the app."
  type        = string
}

variable "gcp_service_account_id" {
  description = "Service account ID for Aperium runtime workloads."
  type        = string
  default     = "aperium-k8s"
}

variable "k8s_service_accounts" {
  description = "Kubernetes service accounts (namespace/name) allowed to impersonate the GSA."
  type        = list(string)
  default     = ["aperium/aperium"]
}

variable "app_project_roles" {
  description = "Project-level IAM roles granted to the app runtime GSA."
  type        = list(string)
  default = [
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
    "roles/cloudprofiler.agent",
    "roles/bigquery.jobUser",
    "roles/secretmanager.secretAccessor",
  ]
}

variable "enable_artifact_registry" {
  description = "Create Artifact Registry repo for Aperium images."
  type        = bool
  default     = true
}

variable "gar_repository_id" {
  description = "Artifact Registry repository ID."
  type        = string
  default     = "aperium"
}

variable "enable_storage_bucket" {
  description = "Create primary GCS bucket for app object storage."
  type        = bool
  default     = true
}

variable "storage_bucket_name" {
  description = "Primary GCS bucket name for Aperium."
  type        = string
  default     = "aperium-prod"
}

variable "storage_bucket_location" {
  description = "Bucket location for app object storage."
  type        = string
  default     = "US"
}

variable "enable_secret_manager" {
  description = "Create Secret Manager secret containers used by Aperium."
  type        = bool
  default     = true
}

variable "app_secret_ids" {
  description = "Secret Manager secret IDs required by the app runtime."
  type        = list(string)
  default = [
    "aperium-backend-yml",
    "aperium-mcp-auth-token",
    "qdrant-api-keys",
    "aperium-keda-db-url",
  ]
}

variable "enable_bigquery" {
  description = "Create BigQuery dataset for Aperium tabular workflows."
  type        = bool
  default     = true
}

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID for tabular features."
  type        = string
  default     = "aperium_tabular"
}

variable "bigquery_location" {
  description = "BigQuery dataset location."
  type        = string
  default     = "US"
}

variable "db_machine_type" {
  description = "Cloud SQL machine type."
  type        = string
  default     = "db-custom-1-3840"
}

variable "db_edition" {
  description = "Cloud SQL edition."
  type        = string
  default     = "ENTERPRISE"
}

variable "aperium_database_name" {
  description = "Aperium PostgreSQL database name."
  type        = string
  default     = "aperium"
}

variable "aperium_keda_db_secret_id" {
  description = "Secret Manager secret id for dedicated KEDA Postgres connection."
  type        = string
  default     = "aperium-keda-db-url"
}

variable "aperium_keda_db_username" {
  description = "Dedicated Cloud SQL username for KEDA queue scaler grants."
  type        = string
  default     = "aperium_keda_reader"
}

variable "enable_cloudsql" {
  description = "Scaffold Cloud SQL resources when true."
  type        = bool
  default     = false
}

variable "adopt_existing_aperium_database" {
  description = "One-time import switch for environments where the Aperium DB already exists but postgresql_database.aperium is not in Terraform state yet."
  type        = bool
  default     = false
}

variable "enable_postgresql_grants" {
  description = "Manage additional in-database PostgreSQL roles/grants (beyond base database ownership) using the postgresql provider."
  type        = bool
  default     = false
}

variable "enable_redis" {
  description = "Scaffold Redis resources when true."
  type        = bool
  default     = false
}

variable "redis_tier" {
  description = "Redis tier (BASIC or STANDARD_HA)."
  type        = string
  default     = "BASIC"
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB."
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis version."
  type        = string
  default     = "REDIS_7_2"
}
