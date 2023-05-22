variable "project_id" {
  type = string
  description = "project_id"
}
variable "region" {
  type = string
  description = "region"
}
variable "project_suffix" {
  type = string
  description = "Optinal suffix for unique project identification"
}
variable "gke_num_nodes" {
  type = number
  default = 1
  description = "number of gke nodes"
}
