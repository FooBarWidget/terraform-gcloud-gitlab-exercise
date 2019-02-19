data "google_dns_managed_zone" "notejam" {
  name = "notejam"
}

resource "google_compute_address" "gitlab" {
  name = "gitlab"
}

resource "google_dns_record_set" "gitlab" {
  name = "gitlab.${data.google_dns_managed_zone.notejam.dns_name}"
  type = "A"
  ttl  = "${var.dns_ttl}"
  managed_zone = "${data.google_dns_managed_zone.notejam.name}"
  rrdatas = ["${google_compute_address.gitlab.address}"]
}

resource "google_compute_instance" "gitlab" {
  name = "gitlab"
  depends_on = ["google_dns_record_set.gitlab"]
  machine_type = "${var.gitlab_machine_type}"
  hostname = "gitlab.${var.root_domain}"
  tags = ["http-server", "https-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      type = "pd-ssd"
      size = 40
      image = "family/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "${google_compute_network.private_gitlab_network.name}"

    access_config {
      nat_ip = "${google_compute_address.gitlab.address}"
    }
  }

  metadata {
    ssh-keys = "${var.instance_ssh_keys}"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/logging.write"
    ]
  }
}

# Provision the Gitlab instance using Ansible.
resource "null_resource" "gitlab-ansible" {
  depends_on = [
    "google_compute_firewall.private_gitlab_network_allow_ssh",
    "google_compute_firewall.private_gitlab_network_allow_https",
    "google_sql_user.gitlab",
    "google_sql_database.gitlab",
    "google_dns_record_set.gitlab-db"
  ]

  triggers {
    gitlab_id = "${google_compute_instance.gitlab.instance_id}"
    database_id = "${google_sql_database_instance.gitlab.id}"
    password = "${var.gitlab_db_password}"
  }

  # Wait until SSH is available.
  provisioner "remote-exec" {
    inline = ["true"]

    connection {
      type = "ssh"
      user = "ansible"
      host = "${google_compute_address.gitlab.address}"
    }
  }

  provisioner "local-exec" {
    command = "./run-ansible 'ansible@${google_compute_address.gitlab.address}' gitlab-playbook.yml -bv"
  }
}
