provider "google" {
  project = "coen-parbhat-rai"
}

terraform {
  backend "gcs" {
    bucket = "cp-task"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.57.0"
    }
  }
}