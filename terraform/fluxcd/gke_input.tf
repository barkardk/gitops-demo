variable "project_id" {
  type        = string
  description = "project_id"
}
variable "project_name" {
  type        = string
  description = "project_name"
}
variable "region" {
  type        = string
  description = "region"
  default     = "us-central1"
}
variable "gke_num_nodes" {
  type        = number
  default     = 1
  description = "number of gke nodes"
}
variable "cluster_name" {
  type        = string
  description = "cluster_name"
}
variable "secret_sa" {
  type = string
  default = "secret-sa"
  description = "Service account used to mount secret fro GCP to k8s"
}
variable "csi_driver_service_account" {
  type = string
  default = "secrets-store-csi-driver-provider-gcp"
  description = "Service account created by the csi driver"
}