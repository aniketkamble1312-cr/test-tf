# Terraform Backend Configuration for QA Load Balancer

terraform {
  required_version = ">= 1.9.0"

  backend "gcs" {
    bucket = "cr-terraform-state-qa"
    prefix = "environments/qa/networking/load-balancer"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

