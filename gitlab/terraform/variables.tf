variable "gcloud_project" {
  description = "Google Cloud project to use"
}

variable "zone" {
  default = "europe-west4-a"
  description = "Google Cloud zone"
}

variable "dns_ttl" {
  default = 3600
}

variable "root_domain" { }

variable "instance_ssh_keys" { }

variable "gitlab_machine_type" {
  default = "n1-standard-2"
  description = "Machine type for Gitlab instances"
}

variable "gitlab_runner_machine_type" {
  default = "n1-standard-2"
  description = "Machine type for Gitlab Runner instances"
}

variable "gitlab_db_machine_type" {
  default = "db-custom-1-3840"
  description = "Machine type for Gitlab database instances"
}

variable "gitlab_db_password" { }

variable "gitlab_backup_bucket_location" {
  default = "europe-west3"
}
