# Terraform Backend Configuration for QA Load Balancer

terraform {
  backend "gcs" {
    bucket = "cr-terraform-state-qa"
    prefix = "environments/qa/networking/load-balancer"
  }
}

