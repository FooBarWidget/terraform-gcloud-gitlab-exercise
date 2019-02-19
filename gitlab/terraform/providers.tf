provider "null" {
  version = "~> 2.0"
}

provider "random" {
  version = "~> 2.0"
}

provider "google" {
  version = "~> 2.0"
  zone = "${var.zone}"
  project = "${var.gcloud_project}"
}

provider "google-beta" {
  version = "~> 2.0"
  zone = "${var.zone}"
  project = "${var.gcloud_project}"
}
