variable "project_id" {
  type = string
  description = "project_id"
}
variable "region" {
  type = string
  description = "region"
}

variable "gke_num_nodes" {
  type = number
  default = 1
  description = "number of gke nodes"
}

variable repository_url {
  type = string
  default = "https://github.com:barkardk/gitops-demo-flux.git"
  description = "Full url to source code repository"
}
