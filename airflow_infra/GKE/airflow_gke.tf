provider "google" {
    project = "gitlab-analysis"
    region  = "us-west1"
    zone    = "us-west1-a" 
}

resource "google_container_cluster" "airflow-cluster" {
    name     = var.environment == "production" ? "data-ops" : "data-ops-${var.environment}"
    location = var.region
    remove_default_node_pool = true
    initial_node_count       = 1
}

resource "google_container_node_pool" "highmem-pool" {
    name        = var.environment == "production" ? "highmem-pool" : "highmem-pool-${var.environment}"
    cluster     = google_container_cluster.airflow-cluster.name
    autoscaling {
        min_node_count = 1
        max_node_count = 2
    }

    node_config {
        machine_type    = "n1-highmem-4"
        service_account = google_service_account.default.email
        oauth_scopes    = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}

resource "google_container_node_pool" "production-task-pool" {
    name    = "${var.environment}-task-pool"
    cluster = google_container_cluster.airflow_cluster.name
    autoscaling {
        min_node_count = 2
        max_node_count = 5
    }

    node_config {
        machine_type    = "n1-highmem-4"
        service_account = google_service_account.default.email
        oauth_scopes    = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
        taint = [
            {
                effect = "NO_SCHEDULE",
                key    = "production",
                value  = "true"
            }
        ]
    }
}

resource "google_container_node_pool" "scd" {
    name    = var.environment == "production" ? "scd-1" : "scd-${var.environment}"
    cluster = google_container_cluster.airflow_cluster.name
    autoscaling {
        min_node_count = 1
        max_node_count = 3
    }

    node_config {
        machine_type    = "n1-highmem-4"
        service_account = google_service_account.default.email
        oauth_scopes    = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
        taint = [
            {
                effect = "NO_SCHEDULE",
                key    = "scd",
                value  = "true"
            }
        ]
    }
}

resource "google_container_node_pool" "testing-task-pool" {
    name    = var.environment == "production" ? "testing-pool" : "${var.environment}-testing-pool"
    cluster = google_container_cluster.airflow_cluster.name
    autoscaling {
        min_node_count = 0
        max_node_count = 1
    }

    node_config {
        machine_type    = "n1-highmem-4"
        service_account = google_service_account.default.email
        oauth_scopes    = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
        taint = [
            {
                effect = "NO_SCHEDULE",
                key    = "test",
                value  = "true"
            }
        ]
    }
}