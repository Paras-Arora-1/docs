output "gcp_service_account_email" {
  description = "App runtime Google service account email."
  value       = google_service_account.aperium_runtime.email
}

output "gar_name" {
  description = "Artifact Registry repository name (if enabled)."
  value       = try(google_artifact_registry_repository.aperium[0].name, null)
}

output "gar_repository_url" {
  description = "Artifact Registry Docker URL (if enabled)."
  value = try(
    "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.aperium[0].repository_id}",
    null,
  )
}

output "storage_bucket_name" {
  description = "Primary app storage bucket name (if enabled)."
  value       = try(google_storage_bucket.aperium[0].name, null)
}

output "secret_ids" {
  description = "Secret Manager IDs managed by this stack."
  value       = keys(google_secret_manager_secret.app)
}

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID (if enabled)."
  value       = try(google_bigquery_dataset.aperium_tabular[0].dataset_id, null)
}

output "db_instance" {
  description = "Cloud SQL instance name (if enabled)."
  value       = try(google_sql_database_instance.instance[0].name, null)
}

output "cloudsql_sa_user" {
  description = "Cloud SQL IAM user for app service account (if enabled)."
  value       = try(google_sql_user.iam_service_account_user[0].name, null)
}

output "cloudsql_keda_user" {
  description = "Cloud SQL built-in user dedicated to KEDA document worker scaling (if enabled)."
  value       = try(google_sql_user.keda_reader[0].name, null)
}

output "keda_db_secret_version" {
  description = "Secret Manager version for the KEDA DB connection payload (if enabled)."
  value       = try(google_secret_manager_secret_version.keda_db_url[0].name, null)
}

output "redis_host" {
  description = "Redis host (if enabled)."
  value       = try(google_redis_instance.cache[0].host, null)
}

output "redis_port" {
  description = "Redis port (if enabled)."
  value       = try(google_redis_instance.cache[0].port, null)
}
