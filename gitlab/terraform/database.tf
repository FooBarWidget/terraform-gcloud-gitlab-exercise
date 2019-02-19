resource "google_dns_record_set" "gitlab-db" {
  name = "gitlab-db.${data.google_dns_managed_zone.notejam.dns_name}"
  type = "A"
  # This record isn't queried often, but when it is queried
  # we want any changes to be immediately visible.
  ttl  = 1
  managed_zone = "${data.google_dns_managed_zone.notejam.name}"
  rrdatas = ["${google_sql_database_instance.gitlab.first_ip_address}"]
}

resource "google_sql_database_instance" "gitlab" {
  depends_on = ["google_service_networking_connection.private_gitlab_vpc"]
  database_version = "POSTGRES_9_6"

  settings {
    tier = "${var.gitlab_db_machine_type}"

    backup_configuration {
      enabled = true
      start_time = "03:00"
    }

    maintenance_window {
      day = 7
      hour = 2
    }

    ip_configuration {
      ipv4_enabled = false
      private_network = "${google_compute_network.private_gitlab_network.self_link}"
    }
  }
}

resource "google_sql_user" "gitlab" {
  name = "gitlab"
  instance = "${google_sql_database_instance.gitlab.name}"
  host = "${google_compute_instance.gitlab.network_interface.0.network_ip}"
  password = "${var.gitlab_db_password}"
}

resource "google_sql_database" "gitlab" {
  name = "gitlab"
  instance = "${google_sql_database_instance.gitlab.name}"
  charset = "UTF8"
}
