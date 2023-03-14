module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 6.0"

  project_id   = "coen-parbhat-rai"
  network_name = "cp-task-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "gke-subnet-01"
      subnet_ip             = "10.10.0.0/24"
      subnet_region         = "europe-west4"
      description           = "gke"
      subnet_private_access = "false"
    }
  ]

  secondary_ranges = {
    gke-subnet-01 = [
      {
        range_name    = "gke-subnet-01-pods"
        ip_cidr_range = "192.168.0.0/22"
      },
      {
        range_name    = "gke-subnet-01-services"
        ip_cidr_range = "192.168.4.0/22"
      }
    ]
  }
}