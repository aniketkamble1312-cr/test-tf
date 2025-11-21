# Outputs for QA Load Balancer

output "static_ips" {
  description = "Static IP addresses"
  value       = module.load_balancer.static_ips
}

output "managed_ssl_certificates" {
  description = "Managed SSL certificate details"
  value       = module.load_balancer.managed_ssl_certificates
}

output "security_policies" {
  description = "Security policy details"
  value       = module.load_balancer.security_policies
}

output "http_backend_services" {
  description = "HTTP backend services"
  value       = module.load_balancer.http_backend_services
}

output "url_maps" {
  description = "URL maps"
  value       = module.load_balancer.url_maps
}

output "http_forwarding_rules" {
  description = "HTTP forwarding rules"
  value       = module.load_balancer.http_forwarding_rules
}

output "internal_backend_services" {
  description = "Internal backend services"
  value       = module.load_balancer.internal_backend_services
}

output "internal_forwarding_rules" {
  description = "Internal forwarding rules"
  value       = module.load_balancer.internal_forwarding_rules
}
