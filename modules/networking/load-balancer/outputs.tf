# Load Balancer Module Outputs

output "static_ips" {
  description = "Static IP addresses created"
  value = {
    for k, v in google_compute_global_address.ip : k => {
      id           = v.id
      name         = v.name
      address      = v.address
      address_type = v.address_type
    }
  }
}

output "managed_ssl_certificates" {
  description = "Managed SSL certificate details"
  value = {
    for k, v in google_compute_managed_ssl_certificate.cert : k => {
      id      = v.id
      name    = v.name
      domains = v.managed[0].domains
    }
  }
}

output "security_policies" {
  description = "Security policy details"
  value = {
    for k, v in google_compute_security_policy.policy : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "http_backend_services" {
  description = "HTTP backend service details"
  value = {
    for k, v in google_compute_backend_service.http_backend : k => {
      id        = v.id
      name      = v.name
      self_link = v.self_link
    }
  }
}

output "url_maps" {
  description = "URL map details"
  value = {
    for k, v in google_compute_url_map.url_map : k => {
      id        = v.id
      name      = v.name
      self_link = v.self_link
    }
  }
}

output "http_forwarding_rules" {
  description = "HTTP forwarding rule details"
  value = {
    for k, v in google_compute_global_forwarding_rule.http_forwarding : k => {
      id         = v.id
      name       = v.name
      ip_address = v.ip_address
    }
  }
}

output "default_health_checks" {
  description = "Auto-created default health check details"
  value = {
    for k, v in google_compute_health_check.default : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "custom_health_checks" {
  description = "Custom health check details"
  value = {
    for k, v in google_compute_health_check.hc : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "internal_backend_services" {
  description = "Internal backend service details"
  value = {
    for k, v in google_compute_region_backend_service.internal_backend : k => {
      id        = v.id
      name      = v.name
      self_link = v.self_link
    }
  }
}

output "internal_forwarding_rules" {
  description = "Internal forwarding rule details"
  value = {
    for k, v in google_compute_forwarding_rule.internal_forwarding : k => {
      id         = v.id
      name       = v.name
      ip_address = v.ip_address
    }
  }
}

output "health_checks" {
  description = "Health check details"
  value = {
    for k, v in google_compute_health_check.hc : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "internal_health_checks" {
  description = "Internal health check details"
  value = {
    for k, v in google_compute_region_health_check.internal_hc : k => {
      id   = v.id
      name = v.name
    }
  }
}

