variable repository_url {
  type = string
  default = "https://github.com:barkardk/gitops-demo-flux.git"
  description = "Full url to source code repository"
}


variable argocd_namespace {
  type = string
  default = "argocd"
  description = "Default argocd namespace"
}

