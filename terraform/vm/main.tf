variable "project_id" {
  type = string
}
variable "service_account_id" {
  type = string
}
variable "service_account_name" {
  type = string
  default = "sa-kba"
}
variable "zone" {
    type = string
}
variable "region" {
    type = string
}

provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
  credentials = file("compute-instance.json")
}

provider "tls" {
  // no config needed
}
resource "tls_private_key" "ssh" {
  algorithm = "ECDSA"
}
resource "local_file" "ssh_private_key_pem" {
  content = tls_private_key.ssh.private_key_pem
  filename = ".ssh/google_compute_engine"
  file_permission = "0600"
}

resource "google_compute_network"  "vpc_network"{
  name = "kba-network"
}

resource "google_compute_address"  "static_ip"{
  name = "kba-vm"
}


resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

data "google_client_openid_userinfo" "me" {}
resource "google_compute_instance" "default" {
  name = "sandbox"
  machine_type = "e2-medium"
  zone = var.zone
  project = var.project_id
  tags = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"
    }
  }
  service_account {
    email = var.service_account_id
    scopes = ["cloud-platform"]
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}

output "public_ip" {
  value = google_compute_address.static_ip.address
}

