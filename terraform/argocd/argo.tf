provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}


data "kubectl_filename_list" "install_argocd" {
  pattern = "../../argocd/manifests/bootstrap/argocd/*.yaml"
}

data "kubectl_filename_list" "install_argocd_custom_resources" {
  pattern = "../../argocd/manifest/bootstrap/argocd/applications/*.yaml"
}

resource "kubectl_manifest" "argocd" {
  count              = length(data.kubectl_filename_list.install_argocd.matches)
  yaml_body          = file(element(data.kubectl_filename_list.install_argocd.matches, count.index))
  override_namespace = "argocd"
}
resource "kubectl_manifest" "argocd_custom_resources" {
  count              = length(data.kubectl_filename_list.install_argocd_custom_resources.matches)
  yaml_body          = file(element(data.kubectl_filename_list.install_argocd_custom_resources.matches, count.index))
}