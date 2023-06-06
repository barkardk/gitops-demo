module "argocd" {
  source = "github.com/bloodorangeio/terraform-kubernetes-argocd"

  namespace = "argocd"

  # Set Kubernetes provider to the same as your Argo CD target Kubernetes cluster.
  k8s_provider = "provider.kubernetes"

  # Replace the following variables with your own values.
  argocd_server_hostname = "argocd.example.com"
  argocd_admin_password = "my-secure-password"
  enable_tls = true

  # (Optional) If your Kubernetes cluster is secured using RBAC, set this parameter to true.
  enable_rbac = true
}
