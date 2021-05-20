provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "staging-context"
}

variable "environment" {
    type = string
}

resource "kubernetes_persistent_volume" "airflow_logs" {
    metadata {
        name = var.environment == "production" ? "persistent-airflow-logs" :  "${var.environment}-persistent-airflow-logs"
    }

    spec {
        capacity = {
            storage = var.environment == "production"? "100Gi" : "10Gi"
        }
        access_modes = ["ReadWriteOnce"]        
    }
}

resource "kubernetes_secret" "airflow" {
    metadata {
        name = "airflow"
        namespace = "default"
    }
}

resource "kubernetes_secret" "airflow_testing" {
    metadata {
        name = "airflow"
        namespace = "testing"
    }
}