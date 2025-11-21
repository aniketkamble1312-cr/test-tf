# Provider Configuration for QA Load Balancer

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.credentials_file
}

