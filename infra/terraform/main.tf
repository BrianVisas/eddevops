terraform {
  required_version = ">= 1.8.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_namespace_v1" "platform" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "api" {
  metadata {
    name      = "platform-status-api"
    namespace = kubernetes_namespace_v1.platform.metadata[0].name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "platform-status-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "platform-status-api"
        }
      }

      spec {
        container {
          name  = "api"
          image = var.image

          port {
            container_port = 8000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 3
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "api" {
  metadata {
    name      = "platform-status-api"
    namespace = kubernetes_namespace_v1.platform.metadata[0].name
  }

  spec {
    selector = {
      app = "platform-status-api"
    }

    port {
      port        = 80
      target_port = 8000
    }

    type = "ClusterIP"
  }
}
