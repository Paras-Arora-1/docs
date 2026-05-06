locals {
  enable_pg_database = var.enable_cloudsql
  enable_pg_grants   = var.enable_cloudsql && var.enable_postgresql_grants
}

# This stack previously created the Aperium database with
# google_sql_database.database. Keep the existing DB intact and remove that
# legacy resource from state while transitioning to postgresql_database as the
# single source of truth.
removed {
  from = google_sql_database.database

  lifecycle {
    destroy = false
  }
}

# Optional import path for environments where the Aperium DB exists in Cloud
# SQL but has not yet been managed by the postgresql provider.
import {
  for_each = (local.enable_pg_database && var.adopt_existing_aperium_database) ? toset([var.aperium_database_name]) : toset([])
  to       = postgresql_database.aperium[0]
  id       = each.value
}

# In-PG resources for Aperium workload.
# This connection requires Terraform execution from private-network-reachable
# agents (for example HCP Terraform Agent in-cluster).
provider "postgresql" {
  scheme    = "gcppostgres"
  host      = try(google_sql_database_instance.instance[0].connection_name, "")
  database  = "postgres"
  username  = try(google_sql_user.postgres[0].name, "")
  password  = try(google_sql_user.postgres[0].password, "")
  superuser = false
}

resource "postgresql_database" "aperium" {
  count = local.enable_pg_database ? 1 : 0

  name = var.aperium_database_name
  # Keep database ownership aligned to the runtime IAM database user.
  owner    = google_sql_user.iam_service_account_user[0].name
  provider = postgresql

  depends_on = [
    google_sql_user.postgres,
    google_sql_user.iam_service_account_user,
  ]
}

resource "postgresql_role" "aperium" {
  count = local.enable_pg_grants ? 1 : 0

  name     = "aperium"
  login    = false
  provider = postgresql

  depends_on = [google_sql_user.postgres]
}

resource "postgresql_grant_role" "aperium_to_postgres" {
  count = local.enable_pg_grants ? 1 : 0

  role       = "postgres"
  grant_role = postgresql_role.aperium[0].name
  provider   = postgresql
}

resource "postgresql_grant_role" "aperium_to_iam_sa" {
  count = local.enable_pg_grants ? 1 : 0

  role       = google_sql_user.iam_service_account_user[0].name
  grant_role = postgresql_role.aperium[0].name
  provider   = postgresql

  depends_on = [google_sql_user.iam_service_account_user]
}

resource "postgresql_grant" "aperium_schema_usage" {
  count = local.enable_pg_grants ? 1 : 0

  database    = postgresql_database.aperium[0].name
  role        = postgresql_role.aperium[0].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
  provider    = postgresql

  depends_on = [postgresql_database.aperium]
}

resource "postgresql_grant" "aperium_existing_objects" {
  for_each = local.enable_pg_grants ? {
    table    = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    sequence = ["SELECT", "UPDATE", "USAGE"]
  } : {}

  database    = postgresql_database.aperium[0].name
  role        = postgresql_role.aperium[0].name
  schema      = "public"
  object_type = each.key
  privileges  = each.value
  provider    = postgresql

  depends_on = [postgresql_database.aperium]
}

resource "postgresql_default_privileges" "aperium_objects" {
  for_each = local.enable_pg_grants ? {
    table    = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    sequence = ["SELECT", "UPDATE", "USAGE"]
    function = ["EXECUTE"]
  } : {}

  database    = postgresql_database.aperium[0].name
  role        = postgresql_role.aperium[0].name
  owner       = postgresql_role.aperium[0].name
  schema      = "public"
  object_type = each.key
  privileges  = each.value
  provider    = postgresql

  depends_on = [postgresql_database.aperium]
}
