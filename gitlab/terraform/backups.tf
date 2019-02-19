resource "google_storage_bucket" "gitlab-backup" {
  name = "gitlab-${replace(var.root_domain, ".", "-")}-backup"
  location = "${var.gitlab_backup_bucket_location}"

  lifecycle_rule {
    action = [{
      type = "Delete"
    }]

    condition {
      age = 356
    }
  }
}

resource "google_service_account" "gitlab-backup" {
  account_id = "gitlab-backup"
}

resource "google_storage_bucket_iam_binding" "gitlab-backup" {
  bucket = "${google_storage_bucket.gitlab-backup.name}"
  role = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${google_service_account.gitlab-backup.email}",
  ]
}

resource "google_service_account_key" "gitlab-backup" {
  service_account_id = "${google_service_account.gitlab-backup.name}"
}

# Copy the backup service account key to the Gitlab server.
resource "null_resource" "gitlab-backup-service-account-key" {
  triggers {
    gitlab_id = "${google_compute_instance.gitlab.instance_id}"
    service_account_id = "${google_service_account_key.gitlab-backup.id}"
  }

  provisioner "file" {
    content = "${base64decode(google_service_account_key.gitlab-backup.private_key)}"
    destination = "/home/ansible/google-service-account-key.json"

    connection {
      type = "ssh"
      user = "ansible"
      host = "${google_compute_address.gitlab.address}"
    }
  }

  provisioner "remote-exec" {
    inline = <<EOF
      chmod 600 /home/ansible/google-service-account-key.json
      sudo install -m 600 -o root -g root /home/ansible/google-service-account-key.json /etc/
EOF

    connection {
      type = "ssh"
      user = "ansible"
      host = "${google_compute_address.gitlab.address}"
    }
  }
}
