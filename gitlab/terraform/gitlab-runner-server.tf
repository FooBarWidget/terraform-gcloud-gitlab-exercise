resource "google_compute_instance" "gitlab-runner" {
  name = "gitlab-runner"
  machine_type = "${var.gitlab_runner_machine_type}"
  hostname = "gitlab-runner.${var.root_domain}"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      type = "pd-ssd"
      size = 40
      image = "family/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
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

# Provision the Gitlab Runner instance using Ansible.
resource "null_resource" "gitlab-runner-ansible" {
  depends_on = [
    "google_compute_firewall.private_gitlab_network_allow_ssh",
    "null_resource.gitlab-ansible"
  ]

  triggers {
    gitlab_id = "${google_compute_instance.gitlab-runner.instance_id}"
  }

  # Wait until SSH is available.
  provisioner "remote-exec" {
    inline = ["true"]

    connection {
      type = "ssh"
      user = "ansible"
      host = "${google_compute_instance.gitlab-runner.network_interface.0.access_config.0.nat_ip}"
    }
  }

  provisioner "local-exec" {
    command = "./run-ansible 'ansible@${google_compute_instance.gitlab-runner.network_interface.0.access_config.0.nat_ip}' gitlab-runner-playbook.yml -bv"
  }
}
