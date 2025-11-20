output "random_string" {
  description = "Random string generated for testing"
  value       = random_string.test.result
}

output "pet_name" {
  description = "Random pet name generated"
  value       = random_pet.name.id
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

