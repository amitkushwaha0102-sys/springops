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
resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.springops.metadata[0].name
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"
          port {
            container_port = 3306
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "root123"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "studentdb"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.springops.metadata[0].name
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }
  }
}