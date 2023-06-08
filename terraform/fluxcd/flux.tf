provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}


data "kubectl_file_documents" "create_fluxcd_ns" {
  content = file("../../fluxcd/manifests/bootstrap/secret-store-csi-driver/secret-mgmt/namespace.yaml")
}

resource "kubectl_manifest" "fluxcd_ns" {
  count     = length(data.kubectl_file_documents.create_fluxcd_ns.documents)
  yaml_body = element(data.kubectl_file_documents.create_fluxcd_ns.documents, count.index)
  depends_on = [data.kubectl_file_documents.install_csi_driver_gcp]
}


data "kubectl_file_documents" "create_secret_sa" {
  content = file("../../fluxcd/manifests/bootstrap/secret-store-csi-driver/secret-mgmt/secret-sa.yaml")
}

resource "kubectl_manifest" "secret_sa" {
  count     = length(data.kubectl_file_documents.create_secret_sa.documents)
  yaml_body = element(data.kubectl_file_documents.create_secret_sa.documents, count.index)
  override_namespace = "flux-system"
  depends_on = [data.kubectl_file_documents.create_fluxcd_ns]
}

data "kubectl_file_documents" "create_fluxcd_secret" {
  content = file("../../fluxcd/manifests/bootstrap/secret-store-csi-driver/secret-mgmt/secret.yaml")
}

resource "kubectl_manifest" "secret" {
  count     = length(data.kubectl_file_documents.create_fluxcd_secret.documents)
  yaml_body = element(data.kubectl_file_documents.create_fluxcd_secret.documents, count.index)
  override_namespace = "flux-system"
  depends_on = [data.kubectl_file_documents.create_secret_sa]
}

data "kubectl_path_documents" "install_fluxcd" {
  pattern = "../../fluxcd/manifests/bootstrap/fluxcd/*.yaml"
}

resource "kubectl_manifest" "fluxcd" {
  count     = length(data.kubectl_path_documents.install_fluxcd.documents)
  yaml_body = element(data.kubectl_path_documents.install_fluxcd.documents, count.index)
  override_namespace = "flux-system"
  depends_on = [data.kubectl_file_documents.install_csi_driver]
}
