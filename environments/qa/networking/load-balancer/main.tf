# Load Balancer Configuration for QA Environment

module "load_balancer" {
  source = "../../../../modules/networking/load-balancer"

  # Project and environment
  project_id = var.project_id
  region     = var.region
  labels     = var.common_tags

  # Global Load Balancer
  global_load_balancer_enabled = var.global_load_balancer_enabled
  static_ip_addresses          = var.static_ip_addresses

  # SSL Certificates
  managed_ssl_certificates = var.managed_ssl_certificates

  # Security Policies
  security_policies = var.security_policies

  # Serverless NEG Configuration
  serverless_negs      = var.serverless_negs
  backend_neg_mappings = var.backend_service_mappings

  # HTTP(S) Load Balancer
  http_load_balancer_enabled = var.http_load_balancer_enabled
  https_enabled              = var.https_enabled
  http_backend_services      = var.http_backend_services
  url_maps                   = var.url_maps
  https_proxies              = var.https_proxies
  http_proxies               = var.http_proxies
  http_forwarding_rules      = var.http_forwarding_rules
  health_checks              = var.health_checks

  # Internal Load Balancer (disabled for qa)
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  internal_backend_services      = var.internal_backend_services
  internal_health_checks         = var.internal_health_checks
  internal_forwarding_rules      = var.internal_forwarding_rules
}
