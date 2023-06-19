
data "kustomization" "linkerd" {
  path = "../../fluxcd/kustomize/infrastructure/linkerd"
  depends_on = [google_container_node_pool.primary_nodes]
}

## using the kubestack framework
module "example_nginx" {
  source  = "kbst.xyz/catalog/nginx/kustomization"
  version = "1.7.0-kbst.0" # find the latest version on https://www.kubestack.com/catalog/nginx

  # the configuration here assumes you're using Terraform's default workspace
  # use `terraform workspace list` to see the workspaces
  configuration_base_key = "default"
  configuration = {
    default = {
      replicas = [{
        name  = "ingress-nginx-controller"
        count = 5
      }]
    }
  }
}
