terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
    flux = {
      source = "fluxcd/flux"
    }
  }
  required_version = ">= 0.14"
}