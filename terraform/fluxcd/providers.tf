terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.69.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"

      version = ">= 1.14.0"

    }
    kustomization = {
      source  = "kbst/kustomization"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }

  }
}

provider "kustomization" {
  # one of kubeconfig_path, kubeconfig_raw or kubeconfig_incluster must be set

  #kubeconfig_path =  "~/.kube/config"
  # can also be set using KUBECONFIG_PATH environment variable

  kubeconfig_raw = module.gke_auth.kubeconfig_raw
  # kubeconfig_raw = yamlencode(local.kubeconfig)

  # kubeconfig_incluster = true
}
# This is a chicken/egg if I ever saw one
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context_cluster = "gke_${var.project_id}_${var.region}_${google_container_cluster.primary.name}"
}

