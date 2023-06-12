
# GKE cluster
resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  # A cluster cannot be created unless a node pool is defined. to
  # workaround this and make sure we only have self managed and not default
  # node pools , the default node pool is created and then immediately deleted
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_service_account" "primary" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE cluster ${var.cluster_name} Service Account"
}




resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    service_account = google_service_account.primary.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      env = var.project_id
    }
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-${var.project_name}-gke"]
    metadata     = {
      disable-legacy-endpoints = "true"
    }
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [google_container_cluster.primary]
  create_duration = "30s"
}


module "gke_auth" {
  depends_on           = [time_sleep.wait_30_seconds]
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = google_container_cluster.primary.name
  location             = var.region
  use_private_endpoint = false
}

