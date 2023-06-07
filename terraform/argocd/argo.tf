provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}

provider "kustomization" {
  kubeconfig_path = "~/.kube/config"
}

module "bootstrap" {

}
data "kubectl_file_documents" "install" {
  content = file("../../argocd/manifests/bootstrap/install.yaml")
}


resource "kubectl_manifest" "argocd" {
  count              = length(data.kubectl_file_documents.install.documents)
  yaml_body          = element(data.kubectl_file_documents.install.documents, count.index)
  override_namespace = "argocd"
}