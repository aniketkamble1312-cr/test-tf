terraform {
  required_version = ">= 1.0"
  
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Create a random string resource for testing
resource "random_string" "test" {
  length  = 16
  special = false
  upper   = false
}

# Example variable usage
resource "random_pet" "name" {
  prefix    = var.prefix
  separator = "-"
  length    = 2
}

