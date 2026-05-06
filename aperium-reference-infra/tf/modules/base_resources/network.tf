resource "google_compute_network" "default" {
  name = var.env_name

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "default" {
  name          = var.env_name
  ip_cidr_range = var.network_cidr
  region        = var.gcp_region
  network       = google_compute_network.default.id
  stack_type    = "IPV4_ONLY"

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.service_cidr
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = var.pod_cidr
  }
}

resource "google_compute_router" "router" {
  name    = "${var.env_name}-router"
  region  = google_compute_subnetwork.default.region
  network = google_compute_network.default.id
}

resource "google_compute_address" "nat_ip" {
  count = var.nat_ip_count

  name   = "${var.env_name}-nat-ip-${count.index}"
  region = google_compute_subnetwork.default.region

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router_nat" "nat" {
  name   = "${var.env_name}-router-nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_ip[*].self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.default.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.env_name}-internal-gcp-service-ips"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.name

  depends_on = [google_project_service.servicenetworking]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.default.name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.servicenetworking]
}
