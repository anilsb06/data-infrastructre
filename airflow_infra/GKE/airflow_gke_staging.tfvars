environment = "staging"
network_mode = "default"
subnetwork= "gke-bizops-runner-subnet-37859e17"
min_master_version="1.19.13-gke.1200"
cluster_ipv4_cidr_block="10.200.0.0/14"
services_ipv4_cidr_block="10.204.0.0/20"
highmem_pool_node_count=1
production_task_pool_node_count=0
sdc_task_pool_node_count=0
testing_task_pool_node_count=0