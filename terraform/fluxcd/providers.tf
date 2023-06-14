terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.27.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"

      version = ">= 1.14.0"

    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }

  }
}

provider "kustomization" {}
