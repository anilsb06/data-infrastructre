provider "google" {
    project = "gitlab-analysis"
    region  = "us-west1"
    zone    = "us-west1-a" 
}

variable "environment" {
    type = string
}
variable "network_mode" {
    type = string
}
variable "subnetwork" {
    type = string 
}
variable "min_master_version" {
  type =  string
}

resource "google_container_cluster" "airflow_cluster" {
    provider = google-beta
    name     = var.environment == "production" ? "data-ops" : "data-ops-${var.environment}"
    description = var.environment == "production" ? "Production ELT cluster" : "${var.environment} ELT Cluster"
    network = var.network_mode
    networking_mode = "VPC_NATIVE"
    ip_allocation_policy {
        cluster_ipv4_cidr_block = "10.180.0.0/14"
        services_ipv4_cidr_block = "10.182.224.0/20"
    }
    remove_default_node_pool = true
    subnetwork=var.subnetwork
    initial_node_count       = 1
    min_master_version = var.min_master_version
    release_channel {
      channel="UNSPECIFIED"
    }
    maintenance_policy {
      daily_maintenance_window {
        start_time="15:00"
      }
    }
    notification_config {
        pubsub {
            enabled = false
        }
    }
    vertical_pod_autoscaling {
      enabled=false
    }
    cluster_autoscaling {
        enabled = true
      autoscaling_profile = "BALANCED"
    }
    private_cluster_config {
      enable_private_endpoint = false
    }
}

resource "google_container_node_pool" "highmem-pool" {
    name        = var.environment == "production" ? "highmem-pool" : "highmem-pool-${var.environment}"
    cluster     = google_container_cluster.airflow_cluster.name
    autoscaling {
        min_node_count = 1
        max_node_count = 2
    }
    node_config {
        machine_type    = "n1-highmem-4"
        image_type = "COS"
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
        image_type = "COS"
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
        image_type = "COS"
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
        image_type = "COS"
        taint = [
            {
                effect = "NO_SCHEDULE",
                key    = "test",
                value  = "true"
            }
        ]
    }
}