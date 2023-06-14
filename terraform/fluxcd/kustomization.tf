
data "kustomization" "linkerd" {
  path = "../../fluxcd/kustomize/infrastructure/linkerd"
  depends_on = [google_container_node_pool.primary_nodes]
}

