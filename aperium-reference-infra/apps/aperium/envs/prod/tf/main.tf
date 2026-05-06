terraform {
  cloud {
    organization = "YOUR_TFC_ORG"

    workspaces {
      name = "YOUR_APP_WORKSPACE"
    }
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }

  required_version = "~> 1.14.0"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}
