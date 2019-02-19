resource "google_compute_network" "private_gitlab_network" {
  name = "private-gitlab-network"
}

resource "google_compute_global_address" "private_gitlab_ips" {
  provider = "google-beta"
  name = "private-gitlab-ips"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 20
  network = "${google_compute_network.private_gitlab_network.self_link}"
}

resource "google_service_networking_connection" "private_gitlab_vpc" {
  provider = "google-beta"
  network = "${google_compute_network.private_gitlab_network.self_link}"
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_gitlab_ips.name}"]
}

resource "google_compute_firewall" "private_gitlab_network_allow_ssh" {
  name = "private-gitlab-network-allow-ssh"
  network = "${google_compute_network.private_gitlab_network.name}"
  priority = 65534
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = [22]
  }
}

resource "google_compute_firewall" "private_gitlab_network_allow_https" {
  name = "private-gitlab-network-allow-https"
  network = "${google_compute_network.private_gitlab_network.name}"
  priority = 65534
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = [80, 443]
  }
}
