terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "springops" {
  metadata {
    name = "springops"
    labels = {
      project = "springops"
      env     = "dev"
    }
  }
}
resource "kubernetes_deployment" "student_api" {
  metadata {
    name      = "student-api"
    namespace = kubernetes_namespace.springops.metadata[0].name
    labels = {
      app = "student-api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "student-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "student-api"
        }
      }

      spec {
        container {
          name  = "student-api"
          image = "amit2700/student-api:latest"
          port {
            container_port = 8080
          }
          env {
            name  = "DB_HOST"
            value = "mysql"
          }
          env {
            name  = "DB_NAME"
            value = "studentdb"
          }
          env {
            name  = "DB_USER"
            value = "root"
          }
          env {
            name  = "DB_PASSWORD"
            value = "root123"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "student_api" {
  metadata {
    name      = "student-api"
    namespace = kubernetes_namespace.springops.metadata[0].name
  }

  spec {
    selector = {
      app = "student-api"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "NodePort"
  }
}