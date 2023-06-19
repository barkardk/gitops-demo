data "kubectl_file_documents" "create_argocd_ns" {
  content = file("../../argocd/manifests/bootstrap/argocd/namespace.yaml")
}

data "kubectl_file_documents" "install_argocd" {
  content = file("../../argocd/manifests/bootstrap/argocd/install.yaml")
}

data "kubectl_path_documents" "install_argocd_custom_resources" {
  pattern = "../../argocd/manifests/bootstrap/argocd/applications/*.yaml"
}

resource "kubectl_manifest" "argocd_ns" {
  count     = length(data.kubectl_file_documents.create_argocd_ns.documents)
  yaml_body = element(data.kubectl_file_documents.create_argocd_ns.documents, count.index)
  override_namespace = "argocd"
}

# null_resource with local-exec provisioner to wait some amount of time before continuing
resource "null_resource" "wait_for_argocd" {
  triggers = {
    namespace = var.argocd_namespace
  }
  provisioner "local-exec" {
    command = "echo Waiting for argocd to be available before creating custom resources..."
  }
  provisioner "local-exec" {
    command = "kubectl get ns ${var.argocd_namespace}"
  }
  provisioner "local-exec" {
    command = "kubectl wait --for=condition=available -n ${var.argocd_namespace} --all deployments"
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [null_resource.wait_for_argocd]
  create_duration = "60s"
}

resource "kubectl_manifest" "argocd" {
  count     = length(data.kubectl_file_documents.install_argocd.documents)
  yaml_body = element(data.kubectl_file_documents.install_argocd.documents, count.index)
  override_namespace = "argocd"
  depends_on = [data.kubectl_file_documents.create_argocd_ns]
}

resource "kubectl_manifest" "argocd_custom_resources" {
  count     = length(data.kubectl_path_documents.install_argocd_custom_resources.documents)
  yaml_body = element(data.kubectl_path_documents.install_argocd_custom_resources.documents, count.index)
  depends_on = [data.kubectl_file_documents.install_argocd]
}