module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  project_id                 = module.vpc.project_id
  name                       = "cp-task-gke-cluster"
  region                     = "europe-west4"
  zones                      = ["europe-west4-a", "europe-west4-b", "europe-west4-c"]
  network                    = module.vpc.network_name
  subnetwork                 = "gke-subnet-01"
  ip_range_pods              = "gke-subnet-01-pods"
  ip_range_services          = "gke-subnet-01-services"
  release_channel            = "REGULAR"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling = true
  enable_private_endpoint    = false
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "172.16.10.0/28"
  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "allow-all"
    },
  ]
}