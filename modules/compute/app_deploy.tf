resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = "status-page-app"
    namespace = "default"  # Change this to your desired namespace
    labels = {
      app = "status-page"
    }
  }

  spec {
    replicas = 2  # Adjust based on your scaling needs

    selector {
      match_labels = {
        app = "status-page"
      }
    }

    template {
      metadata {
        labels = {
          app = "status-page"
        }
      }

      spec {
        container {
          name  = "status-page"
          image = "${var.ecr_repository_uri}:latest"  # Adjust the image URI based on your ECR setup
          ports {
            container_port = 8000  # Change if your app uses a different port
          }

          env {
            name  = "DATABASE_URL"
            value = var.database_url  # Reference your DB connection string here
          }

          # Add any additional environment variables, resource limits, etc. here
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name      = "status-page-lb"
    namespace = "default"  # Change this to your desired namespace
  }

  spec {
    selector = {
      app = "status-page"
    }
    type     = "LoadBalancer"  # Use "ClusterIP" or "NodePort" if needed

    port {
      port        = 80         # Change to your desired port
      target_port = 8000       # Change to your container port
    }
  }
}

# Ingress configuration (if needed)
resource "kubernetes_ingress" "app_ingress" {
  metadata {
    name      = "status-page-ingress"
    namespace = "default"  # Change this to your desired namespace
  }

  spec {
    rule {
      http {
        path {
          path    = "/*"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
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

# Outputs for the deployment
output "app_service_ip" {
  value = kubernetes_service.app_service.load_balancer_ingress[0].ip
}

