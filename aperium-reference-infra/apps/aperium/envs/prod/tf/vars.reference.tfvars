# Reference snapshot from the extracted Aperium prod-style environment. Copy values intentionally; do not auto-load this file in a live workspace.
gcp_project_id   = "aperium-apps-prod"
gcp_region       = "us-central1"
gcp_zone         = "us-central1-a"
gcp_network_path = "projects/aperium-apps-prod/global/networks/prod"

enable_artifact_registry        = true
enable_storage_bucket           = true
enable_secret_manager           = true
enable_bigquery                 = true
enable_cloudsql                 = true
adopt_existing_aperium_database = true
enable_postgresql_grants        = true
enable_redis                    = true

storage_bucket_name = "aperium-prod-869488230875"

db_machine_type = "db-custom-1-3840"
db_edition      = "ENTERPRISE"
