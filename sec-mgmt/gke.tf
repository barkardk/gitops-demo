#resource "google_project" "kba-sandbox" {
#
#  # Enable Workload Identity
#  workload_identity_config {
#    identity_namespace = "${var.project_id}.svc.id.goog"
#  }
#}
# GKE cluster
resource "google_container_cluster" "primary" {
  name = "${var.project_id}-${var.project_suffix}-gke"
  location = var.region
  # A cluster cannot be created unless a node pool is defined. to
  # workaround this and make sure we only have self managed and not default
  # node pools , the default node pool is created and then immediately deleted
  remove_default_node_pool = true
  initial_node_count = 1
  network = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "primary_nodes" {
  name = google_container_cluster.primary.name
  location = var.region
  cluster = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      env = var.project_id
    }
    machine_type = "n1-standard-1"
    tags = ["gke-node", "${var.project_id}-${var.project_suffix}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

  }
}

