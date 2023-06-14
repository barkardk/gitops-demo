data "kustomization" "ingress-nginx" {
  provider = kustomization

  path = "../../kustomize/middleware/ingress-nginx"
}
