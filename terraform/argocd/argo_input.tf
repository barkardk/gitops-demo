variable repository_url {
  type = string
  default = "https://github.com:barkardk/gitops-demo-flux.git"
  description = "Full url to source code repository"
}
variable argocd_access_token {
  type = string
  description = "default token to allow argocd access"
}
