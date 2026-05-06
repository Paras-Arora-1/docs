locals {
  enable_keda_db_scaler = var.enable_cloudsql && var.enable_secret_manager
  keda_db_secret_ref    = try(google_secret_manager_secret.app[var.aperium_keda_db_secret_id], null)

  keda_db_connection_url = local.enable_keda_db_scaler ? format(
    "postgresql://%s:%s@%s:5432/%s",
    urlencode(google_sql_user.keda_reader[0].name),
    urlencode(random_password.keda_reader_password[0].result),
    google_sql_database_instance.instance[0].private_ip_address,
    var.aperium_database_name,
  ) : null
}

resource "random_password" "keda_reader_password" {
  count = local.enable_keda_db_scaler ? 1 : 0

  length  = 32
  special = true
}

resource "google_sql_user" "keda_reader" {
  count = local.enable_keda_db_scaler ? 1 : 0

  project         = var.gcp_project_id
  name            = var.aperium_keda_db_username
  instance        = google_sql_database_instance.instance[0].name
  password        = random_password.keda_reader_password[0].result
  deletion_policy = "ABANDON"
}

resource "postgresql_grant_role" "keda_reader_pg_read_all_data" {
  count = local.enable_keda_db_scaler ? 1 : 0

  role       = google_sql_user.keda_reader[0].name
  grant_role = "pg_read_all_data"
  provider   = postgresql

  depends_on = [
    google_sql_user.postgres,
    google_sql_user.keda_reader,
    postgresql_database.aperium,
  ]
}

resource "google_secret_manager_secret_version" "keda_db_url" {
  count = local.enable_keda_db_scaler && local.keda_db_secret_ref != null ? 1 : 0

  secret      = local.keda_db_secret_ref.id
  secret_data = "DATABASE_URL=${local.keda_db_connection_url}"

  depends_on = [
    google_sql_user.keda_reader,
    postgresql_grant_role.keda_reader_pg_read_all_data,
  ]
}
