provider "kustomization" {
  kubeconfig_path = "~/.kube/config"
  # can also be set using KUBECONFIG_PATH environment variable

  # kubeconfig_raw = data.template_file.kubeconfig.rendered
  # kubeconfig_raw = yamlencode(local.kubeconfig)

  # kubeconfig_incluster = true
}

data "kustomization" "ingress-nginx" {
  path = "../../fluxcd/kustomize/middleware/ingress-nginx"
}
