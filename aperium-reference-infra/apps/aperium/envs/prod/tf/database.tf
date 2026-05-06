resource "random_id" "db_name_suffix" {
  count = var.enable_cloudsql ? 1 : 0

  byte_length = 8
}

# Postgres admin credentials used by the postgresql provider for database and grant management.
resource "random_password" "db_admin_password" {
  count = var.enable_cloudsql ? 1 : 0

  length  = 32
  special = true
}

resource "google_sql_database_instance" "instance" {
  count = var.enable_cloudsql ? 1 : 0

  name                = "aperium-${random_id.db_name_suffix[0].hex}"
  project             = var.gcp_project_id
  database_version    = "POSTGRES_17"
  deletion_protection = true

  settings {
    tier    = var.db_machine_type
    edition = var.db_edition

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.gcp_network_path
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      location                       = "us"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }
  }

  depends_on = [google_project_service.required["sqladmin.googleapis.com"]]
}

resource "google_sql_user" "postgres" {
  count = var.enable_cloudsql ? 1 : 0

  project         = var.gcp_project_id
  name            = "postgres"
  instance        = google_sql_database_instance.instance[0].name
  password        = random_password.db_admin_password[0].result
  deletion_policy = "ABANDON"
}

resource "google_sql_user" "iam_service_account_user" {
  count = var.enable_cloudsql ? 1 : 0

  name     = trimsuffix(google_service_account.aperium_runtime.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.instance[0].name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
