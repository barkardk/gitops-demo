terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
    kubectl =  {
      load_config_file       = true
      config_path = "~/.kube/config"
    }
  }
  required_version = ">= 0.14"
  backend "gcs" {
    bucket = "terraform-backend-${var.project_id}-${var.project_name}"
    prefix = "argocd-terraform"
  }
}