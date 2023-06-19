resource "kubernetes_namespace_v1" "nginx" {
  metadata {
    annotations = {
      name = "prometheus.io/scrape: true"
    }

    labels = {
      app = "nginx"
    }

    name = "nginx-tf"
  }
  depends_on = [google_container_node_pool.primary_nodes]
}

resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name = "nginx"
    namespace = "nginx-tf"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
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
  depends_on = [google_container_node_pool.primary_nodes]
}



resource "kubernetes_service_v1" "nginx" {
  metadata {
    name = "nginx"
    namespace = "nginx-tf"
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
  depends_on = [google_container_node_pool.primary_nodes]
}

resource "kubernetes_ingress_v1" "nginx" {
  wait_for_load_balancer = false
  metadata {
    name = "nginx"
    namespace = "nginx-tf"
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
  depends_on = [google_container_node_pool.primary_nodes]
}
