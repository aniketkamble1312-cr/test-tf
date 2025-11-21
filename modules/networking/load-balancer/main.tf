# Load Balancer Module for GCP
# Supports HTTP(S), SSL Proxy, TCP Proxy, and Internal Load Balancing

# ============================================================================
# Locals for Serverless NEG Backend Configuration
# ============================================================================

locals {
  # Consolidate all NEG backends into a single map by type
  all_serverless_negs = merge(
    # Cloud Run NEGs
    {
      for key, neg in google_compute_region_network_endpoint_group.cloud_run :
      "cloud_run/${key}" => {
        group           = neg.id
        balancing_mode  = "UTILIZATION"
        capacity_scaler = 1.0
      }
    },
    # Cloud Function NEGs
    {
      for key, neg in google_compute_region_network_endpoint_group.cloud_function :
      "cloud_function/${key}" => {
        group           = neg.id
        balancing_mode  = "UTILIZATION"
        capacity_scaler = 1.0
      }
    },
    # App Engine NEGs
    {
      for key, neg in google_compute_region_network_endpoint_group.app_engine :
      "app_engine/${key}" => {
        group           = neg.id
        balancing_mode  = "UTILIZATION"
        capacity_scaler = 1.0
      }
    }
  )

  # Map backend services to their NEG backends using the mapping variable
  backend_service_neg_map = {
    for backend_name, mapping in var.backend_neg_mappings :
    backend_name => try([local.all_serverless_negs["${mapping.type}/${mapping.key}"]], [])
  }

  # Normalize backend configurations with consistent attribute sets
  normalized_http_backend_services = [
    for backend in var.http_backend_services : merge(
      {
        name                            = backend.name
        protocol                        = backend.protocol
        load_balancing_scheme           = backend.load_balancing_scheme
        port_name                       = null
        timeout_sec                     = null
        connection_draining_timeout_sec = null
        locality_lb_policy              = null
        session_affinity                = null
        description                     = null
        custom_response_headers         = []
        enable_cdn                      = false
        cdn_policy                      = null
        security_policy                 = null
        enable_logging                  = false
        log_sample_rate                 = null
        health_checks                   = null
        backends                        = []
      },
      backend,
      {
        custom_response_headers = lookup(backend, "custom_response_headers", [])
        cdn_policy              = lookup(backend, "cdn_policy", null)
        health_checks           = lookup(backend, "health_checks", null)
        enable_cdn              = lookup(backend, "enable_cdn", false)
        enable_logging          = lookup(backend, "enable_logging", false)
        log_sample_rate         = lookup(backend, "log_sample_rate", null)
        backends = coalesce(
          lookup(local.backend_service_neg_map, backend.name, null),
          lookup(backend, "backends", [])
        )
      }
    )
  ]

  http_backend_services_with_negs = local.normalized_http_backend_services

  http_backend_services_with_negs_map = {
    for backend in local.normalized_http_backend_services :
    backend.name => backend
  }
}

# ============================================================================
# Serverless Network Endpoint Groups (NEGs)
# ============================================================================

# Cloud Run Serverless NEGs
resource "google_compute_region_network_endpoint_group" "cloud_run" {
  for_each = var.serverless_negs.cloud_run

  project               = var.project_id
  name                  = each.value.service_name
  region                = coalesce(each.value.region, var.region)
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = each.value.service_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Cloud Functions Serverless NEGs
resource "google_compute_region_network_endpoint_group" "cloud_function" {
  for_each = var.serverless_negs.cloud_functions

  project               = var.project_id
  name                  = each.value.function_name
  region                = coalesce(each.value.region, var.region)
  network_endpoint_type = "SERVERLESS"

  cloud_function {
    function = each.value.function_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# App Engine Serverless NEGs
resource "google_compute_region_network_endpoint_group" "app_engine" {
  for_each = var.serverless_negs.app_engine

  project               = var.project_id
  name                  = "app-engine-${each.value.service}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  app_engine {
    service = each.value.service
    version = null # null means all traffic to latest version
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# Load Balancer Resources
# ============================================================================

# Static IP addresses
resource "google_compute_global_address" "ip" {
  for_each = var.global_load_balancer_enabled ? {
    for addr in var.static_ip_addresses : addr.name => addr
  } : {}

  project      = var.project_id
  name         = each.value.name
  address_type = each.value.address_type

  labels = merge(
    var.labels,
    lookup(each.value, "labels", {})
  )
}

# Managed SSL Certificates
resource "google_compute_managed_ssl_certificate" "cert" {
  for_each = var.http_load_balancer_enabled && var.https_enabled ? {
    for cert in var.managed_ssl_certificates : cert.name => cert
  } : {}

  project = var.project_id
  name    = each.value.name

  managed {
    domains = each.value.domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Policies
resource "google_compute_security_policy" "policy" {
  for_each = var.http_load_balancer_enabled ? {
    for policy in var.security_policies : policy.name => policy
  } : {}

  project = var.project_id
  name    = each.value.name

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = lookup(each.value, "enable_layer7_ddos", false)
    }
  }
}

# Backend Service for HTTP(S) Load Balancing
resource "google_compute_backend_service" "http_backend" {
  for_each = var.http_load_balancer_enabled ? local.http_backend_services_with_negs_map : {}

  project                         = var.project_id
  name                            = each.value.name
  protocol                        = each.value.protocol
  load_balancing_scheme           = each.value.load_balancing_scheme
  port_name                       = lookup(each.value, "port_name", "http")
  timeout_sec                     = lookup(each.value, "timeout_sec", 30)
  enable_cdn                      = lookup(each.value, "enable_cdn", false)
  connection_draining_timeout_sec = lookup(each.value, "connection_draining_timeout_sec", 0)
  locality_lb_policy              = lookup(each.value, "locality_lb_policy", "ROUND_ROBIN")
  session_affinity                = lookup(each.value, "session_affinity", "NONE")
  description                     = lookup(each.value, "description", null)
  custom_response_headers         = lookup(each.value, "custom_response_headers", [])

  security_policy = lookup(each.value, "security_policy", null) != null ? google_compute_security_policy.policy[each.value.security_policy].id : null

  # Health checks - only for non-serverless backends
  # Serverless backends (Cloud Run, Cloud Functions, App Engine) do not support health checks
  # For serverless, set to null to omit the attribute entirely
  health_checks = (
    # If custom health_checks are specified, use them
    lookup(each.value, "health_checks", null) != null && length(each.value.health_checks) > 0 ? [
      for hc in each.value.health_checks : google_compute_health_check.hc[hc].id
    ] : (
      # If no backends are defined yet (empty []), use default health check
      # If backends are defined (serverless NEGs), set to null to omit health checks
      length(lookup(each.value, "backends", [])) == 0 ? [google_compute_health_check.default[each.value.name].id] : null
    )
  )

  dynamic "backend" {
    for_each = lookup(each.value, "backends", [])
    content {
      group           = backend.value.group
      balancing_mode  = lookup(backend.value, "balancing_mode", "UTILIZATION")
      capacity_scaler = lookup(backend.value, "capacity_scaler", 1)
      max_utilization = lookup(backend.value, "max_utilization", 0.8)
      max_rate        = lookup(backend.value, "max_rate", null)
      max_connections = lookup(backend.value, "max_connections", null)
    }
  }

  dynamic "cdn_policy" {
    for_each = lookup(each.value, "enable_cdn", false) && lookup(each.value, "cdn_policy", null) != null ? [1] : []
    content {
      default_ttl                  = lookup(each.value.cdn_policy, "default_ttl", 3600)
      max_ttl                      = lookup(each.value.cdn_policy, "max_ttl", 86400)
      client_ttl                   = lookup(each.value.cdn_policy, "client_ttl", 3600)
      negative_caching             = lookup(each.value.cdn_policy, "negative_caching", false)
      serve_while_stale            = lookup(each.value.cdn_policy, "serve_while_stale", 0)
      cache_mode                   = lookup(each.value.cdn_policy, "cache_mode", "CACHE_ALL_STATIC")
      signed_url_cache_max_age_sec = lookup(each.value.cdn_policy, "signed_url_cache_max_age_sec", 0)

      dynamic "cache_key_policy" {
        for_each = lookup(each.value.cdn_policy, "cache_key_policy", null) != null ? [1] : []
        content {
          include_host         = lookup(each.value.cdn_policy.cache_key_policy, "include_host", true)
          include_protocol     = lookup(each.value.cdn_policy.cache_key_policy, "include_protocol", true)
          include_query_string = lookup(each.value.cdn_policy.cache_key_policy, "include_query_string", true)
        }
      }
    }
  }

  log_config {
    enable      = lookup(each.value, "enable_logging", false)
    sample_rate = lookup(each.value, "enable_logging", false) ? lookup(each.value, "log_sample_rate", 1.0) : 0
  }
}

# URL Map for HTTP(S) Load Balancing
resource "google_compute_url_map" "url_map" {
  for_each = var.http_load_balancer_enabled ? {
    for map in var.url_maps : map.name => map
  } : {}

  project     = var.project_id
  name        = each.value.name
  description = lookup(each.value, "description", null)

  default_service = lookup(each.value, "default_service", null) != null ? google_compute_backend_service.http_backend[each.value.default_service].id : null

  dynamic "default_url_redirect" {
    for_each = lookup(each.value, "default_url_redirect", null) != null ? [1] : []
    content {
      https_redirect         = lookup(each.value.default_url_redirect, "https_redirect", true)
      redirect_response_code = lookup(each.value.default_url_redirect, "redirect_response_code", "MOVED_PERMANENTLY_DEFAULT")
      strip_query            = lookup(each.value.default_url_redirect, "strip_query", false)
    }
  }

  dynamic "host_rule" {
    for_each = lookup(each.value, "host_rules", [])
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = lookup(each.value, "path_matchers", [])
    content {
      name            = path_matcher.value.name
      default_service = lookup(path_matcher.value, "default_service", null) != null ? google_compute_backend_service.http_backend[path_matcher.value.default_service].id : null

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rules", [])
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.http_backend[path_rule.value.service].id
        }
      }
    }
  }
}

# HTTP(S) Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  for_each = var.http_load_balancer_enabled && var.https_enabled ? {
    for proxy in var.https_proxies : proxy.name => proxy
  } : {}

  project                     = var.project_id
  name                        = each.value.name
  url_map                     = google_compute_url_map.url_map[each.value.url_map_name].id
  ssl_certificates            = [for cert_name in each.value.ssl_certificates : google_compute_managed_ssl_certificate.cert[cert_name].id]
  http_keep_alive_timeout_sec = lookup(each.value, "http_keep_alive_timeout_sec", 100)
  quic_override               = lookup(each.value, "quic_override", "NONE")
}

resource "google_compute_target_http_proxy" "http_proxy" {
  for_each = var.http_load_balancer_enabled ? {
    for proxy in var.http_proxies : proxy.name => proxy
  } : {}

  project = var.project_id
  name    = each.value.name
  url_map = google_compute_url_map.url_map[each.value.url_map_name].id
}

# Forwarding Rules for HTTP(S) LB
resource "google_compute_global_forwarding_rule" "http_forwarding" {
  for_each = var.http_load_balancer_enabled ? {
    for rule in var.http_forwarding_rules : rule.name => rule
  } : {}

  project               = var.project_id
  name                  = each.value.name
  target                = lookup(each.value, "is_https", true) ? google_compute_target_https_proxy.https_proxy[each.value.target_proxy_name].id : google_compute_target_http_proxy.http_proxy[each.value.target_proxy_name].id
  ip_address            = lookup(each.value, "ip_address_name", null) != null ? google_compute_global_address.ip[each.value.ip_address_name].address : null
  ip_protocol           = "TCP"
  port_range            = lookup(each.value, "port_range", "443")
  load_balancing_scheme = lookup(each.value, "load_balancing_scheme", "EXTERNAL_MANAGED")

  labels = merge(
    var.labels,
    lookup(each.value, "labels", {})
  )
}

# Default Health Checks for backend services (auto-created)
resource "google_compute_health_check" "default" {
  for_each = var.http_load_balancer_enabled ? {
    for backend in var.http_backend_services : backend.name => backend
    if lookup(backend, "health_checks", null) == null || length(lookup(backend, "health_checks", [])) == 0
  } : {}

  project = var.project_id
  name    = "${each.value.name}-default-hc"

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/"
    proxy_header = "NONE"
  }

  log_config {
    enable = false
  }
}

# Custom Health Checks (explicitly defined)
resource "google_compute_health_check" "hc" {
  for_each = var.http_load_balancer_enabled ? {
    for hc in var.health_checks : hc.name => hc
  } : {}

  project = var.project_id
  name    = each.value.name

  check_interval_sec  = lookup(each.value, "check_interval_sec", 10)
  timeout_sec         = lookup(each.value, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value, "unhealthy_threshold", 3)

  http_health_check {
    port         = lookup(each.value, "port", 80)
    request_path = lookup(each.value, "request_path", "/")
    proxy_header = lookup(each.value, "proxy_header", "NONE")
  }

  log_config {
    enable = lookup(each.value, "enable_logging", false)
  }
}

# Internal Load Balancer
resource "google_compute_region_backend_service" "internal_backend" {
  for_each = var.internal_load_balancer_enabled ? {
    for backend in var.internal_backend_services : backend.name => backend
  } : {}

  project               = var.project_id
  name                  = each.value.name
  region                = each.value.region
  protocol              = each.value.protocol
  load_balancing_scheme = "INTERNAL"
  timeout_sec           = lookup(each.value, "timeout_sec", 30)

  health_checks = [for hc in lookup(each.value, "health_checks", []) : google_compute_region_health_check.internal_hc[hc].id]

  network = each.value.network

  dynamic "backend" {
    for_each = lookup(each.value, "backends", [])
    content {
      group          = backend.value.group
      balancing_mode = lookup(backend.value, "balancing_mode", "CONNECTION")
    }
  }
}

resource "google_compute_region_health_check" "internal_hc" {
  for_each = var.internal_load_balancer_enabled ? {
    for hc in var.internal_health_checks : hc.name => hc
  } : {}

  project = var.project_id
  name    = each.value.name
  region  = each.value.region

  http_health_check {
    port         = lookup(each.value, "port", 80)
    request_path = lookup(each.value, "request_path", "/")
  }

  log_config {
    enable = lookup(each.value, "enable_logging", false)
  }
}

resource "google_compute_forwarding_rule" "internal_forwarding" {
  for_each = var.internal_load_balancer_enabled ? {
    for rule in var.internal_forwarding_rules : rule.name => rule
  } : {}

  project               = var.project_id
  name                  = each.value.name
  region                = each.value.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.internal_backend[each.value.backend_service_name].self_link
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  ports                 = lookup(each.value, "ports", ["80"])
}
