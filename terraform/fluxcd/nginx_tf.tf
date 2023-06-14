resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name = "nginx"
    namespace = "nginx-tf"
    app = "nginx"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
data "kubernetes_namespace_v1" "nginx-tf" {
  metadata {
    name = "nginx-tf"
  }
}

resource "kubernetes_service_v1" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  wait_for_load_balancer = true
  metadata {
    app = "nginx"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service_v1.nginx.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}



output "load_balancer" {
  value = kubernetes_ingress_v1.nginx.status
}