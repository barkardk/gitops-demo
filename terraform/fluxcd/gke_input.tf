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
