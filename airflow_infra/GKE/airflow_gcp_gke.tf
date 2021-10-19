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
    project = "gitlab-analysis"
    location = "us-west1-a"
    provider = google-beta
    name     = var.environment == "production" ? "data-ops" : "data-ops-${var.environment}"
    description = var.environment == "production" ? "Production ELT cluster" : "${var.environment} ELT Cluster"
    network = var.network_mode
    networking_mode = "VPC_NATIVE"
    ip_allocation_policy {
        cluster_ipv4_cidr_block = "10.200.0.0/14"
        services_ipv4_cidr_block = "10.204.0.0/20"
    }
    remove_default_node_pool = true
    subnetwork=var.subnetwork
    initial_node_count       = 1
    min_master_version = var.min_master_version
    addons_config {
      horizontal_pod_autoscaling {
        disabled=true
      }
    }
   release_channel {
        channel="UNSPECIFIED"
    }
    notification_config {
        pubsub {
            enabled = false
        }
    }
    vertical_pod_autoscaling {
        enabled=false
    }
    private_cluster_config {
        enable_private_endpoint = false
    }
}

resource "google_container_node_pool" "highmem-pool" {
    name        = var.environment == "production" ? "highmem-pool" : "highmem-pool-${var.environment}"
    location = "us-west1-a"
    cluster     = google_container_cluster.airflow_cluster.name
    autoscaling {
        min_node_count = 1
        max_node_count = 2
    }
    node_count = 2
    node_config {
        machine_type    = "n1-highmem-4"
        image_type = "COS"
    }
}

resource "google_container_node_pool" "production-task-pool" {
    name    = "${var.environment}-task-pool"
    location = "us-west1-a"
    cluster = google_container_cluster.airflow_cluster.name
    node_count = 2
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

resource "google_container_node_pool" "sdc" {
    name    = var.environment == "production" ? "sdc-1" : "sdc-${var.environment}"
    location = "us-west1-a"
    cluster = google_container_cluster.airflow_cluster.name
    node_count = 1
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
                key    = "sdc",
                value  = "true"
            }
        ]
    }
}

resource "google_container_node_pool" "testing-task-pool" {
    name    = var.environment == "production" ? "testing-pool" : "${var.environment}-testing-pool"
    location = "us-west1-a"
    cluster = google_container_cluster.airflow_cluster.name
    autoscaling {
        min_node_count = 0
        max_node_count = 1
    }
    node_count = 0

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