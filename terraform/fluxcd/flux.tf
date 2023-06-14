provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}


data "kubectl_path_documents" "install_fluxcd" {
  pattern = "../../fluxcd/clusters/sandbox/flux-system/*.yaml"
}

resource "kubectl_manifest" "fluxcd" {
  count     = length(data.kubectl_path_documents.install_fluxcd.documents)
  yaml_body = element(data.kubectl_path_documents.install_fluxcd.documents, count.index)
  override_namespace = "flux-system"
}

data "kubectl_file_documents" "install_common" {
  content = file("../../fluxcd/clusters/sandbox/sandbox/infrastructure.yaml")
}

resource "kubectl_manifest" "common" {
  count     = length(data.kubectl_file_documents.install_common.documents)
  yaml_body = element(data.kubectl_file_documents.install_common.documents, count.index)
  override_namespace = "flux-system"
  depends_on = [kubectl_manifest.fluxcd]
}

data "kubectl_file_documents" "install_infrastrucure" {
  content = file("../../fluxcd/clusters/sandbox/sandbox/common.yaml")
}

resource "kubectl_manifest" "infrastructure" {
  count     = length(data.kubectl_file_documents.install_infrastrucure.documents)
  yaml_body = element(data.kubectl_file_documents.install_infrastrucure, count.index)
  override_namespace = "flux-system"
  depends_on = [kubectl_manifest.fluxcd]
}
