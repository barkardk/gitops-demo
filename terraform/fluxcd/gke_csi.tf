data "kubectl_file_documents" "install_csi_driver" {
  content = file("../../fluxcd/manifests/bootstrap/secret-store-csi-driver/csi-driver.yaml")
}

resource "kubectl_manifest" "install_csi_driver" {
  count     = length(data.kubectl_file_documents.install_csi_driver.documents)
  yaml_body = element(data.kubectl_file_documents.install_csi_driver.documents, count.index)
}


data "kubectl_file_documents" "install_csi_driver_gcp" {
  content = file("../../fluxcd/manifests/bootstrap/secret-store-csi-driver/csi-driver-gcp.yaml")
}

resource "kubectl_manifest" "install_csi_driver_gcp" {
  count     = length(data.kubectl_file_documents.install_csi_driver_gcp.documents)
  yaml_body = element(data.kubectl_file_documents.install_csi_driver_gcp.documents, count.index)
  depends_on = [kubectl_manifest.install_csi_driver]
}

# null_resource with local-exec provisioner to wait some amount of time before continuing
resource "null_resource" "wait_for_csi_driver" {
  provisioner "local-exec" {
    command = "echo Waiting for fluxcd to be available before creating custom resources..."
  }
  provisioner "local-exec" {
    command = "kubectl get sa ${var.csi_driver_service_account} -n kube-system"
  }
}

resource "time_sleep" "wait_cs_60_seconds" {
  depends_on = [null_resource.wait_for_csi_driver]
  create_duration = "60s"
}
