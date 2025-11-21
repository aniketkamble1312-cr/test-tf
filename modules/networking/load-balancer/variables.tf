# Load Balancer Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
}

variable "labels" {
  description = "Common labels to apply to resources"
  type        = map(string)
  default     = {}
}

# Global Load Balancer Configuration
variable "global_load_balancer_enabled" {
  description = "Enable global load balancer"
  type        = bool
  default     = false
}

variable "static_ip_addresses" {
  description = "List of static IP addresses to create"
  type = list(object({
    name         = string
    address_type = optional(string, "EXTERNAL")
    labels       = optional(map(string), {})
  }))
  default = []
}

# SSL Certificates
variable "managed_ssl_certificates" {
  description = "List of managed SSL certificates to create"
  type = list(object({
    name    = string
    domains = list(string)
  }))
  default = []
}

# Security Policies
variable "security_policies" {
  description = "List of security policies to create"
  type = list(object({
    name               = string
    enable_layer7_ddos = optional(bool, false)
  }))
  default = []
}

# HTTP(S) Load Balancer Configuration
variable "http_load_balancer_enabled" {
  description = "Enable HTTP(S) load balancer"
  type        = bool
  default     = false
}

variable "https_enabled" {
  description = "Enable HTTPS (SSL/TLS)"
  type        = bool
  default     = false
}

variable "http_backend_services" {
  description = "HTTP backend service configurations"
  type = list(object({
    name                            = string
    protocol                        = string
    load_balancing_scheme           = string
    port_name                       = optional(string, "http")
    timeout_sec                     = optional(number, 30)
    connection_draining_timeout_sec = optional(number, 0)
    locality_lb_policy              = optional(string, "ROUND_ROBIN")
    session_affinity                = optional(string, "NONE")
    description                     = optional(string)
    enable_cdn                      = optional(bool, false)
    enable_logging                  = optional(bool, false)
    log_sample_rate                 = optional(number, 1.0)
    health_checks                   = optional(list(string), [])
    security_policy                 = optional(string)
    custom_response_headers         = optional(list(string), [])
    backends = optional(list(object({
      group           = string
      balancing_mode  = optional(string, "UTILIZATION")
      capacity_scaler = optional(number, 1)
      max_utilization = optional(number, 0.8)
      max_rate        = optional(number)
      max_connections = optional(number)
    })), [])
    cdn_policy = optional(object({
      default_ttl                  = optional(number, 3600)
      max_ttl                      = optional(number, 86400)
      client_ttl                   = optional(number, 3600)
      negative_caching             = optional(bool, false)
      serve_while_stale            = optional(number, 0)
      cache_mode                   = optional(string, "CACHE_ALL_STATIC")
      signed_url_cache_max_age_sec = optional(number, 0)
      cache_key_policy = optional(object({
        include_host         = optional(bool, true)
        include_protocol     = optional(bool, true)
        include_query_string = optional(bool, true)
      }))
    }))
  }))
  default = []
}

variable "url_maps" {
  description = "URL map configurations"
  type = list(object({
    name            = string
    description     = optional(string)
    default_service = optional(string)
    default_url_redirect = optional(object({
      https_redirect         = optional(bool, true)
      redirect_response_code = optional(string, "MOVED_PERMANENTLY_DEFAULT")
      strip_query            = optional(bool, false)
    }))
    host_rules = optional(list(object({
      hosts        = list(string)
      path_matcher = string
    })), [])
    path_matchers = optional(list(object({
      name            = string
      default_service = optional(string)
      path_rules = optional(list(object({
        paths   = list(string)
        service = string
      })), [])
    })), [])
  }))
  default = []
}

variable "https_proxies" {
  description = "HTTPS proxy configurations"
  type = list(object({
    name                        = string
    url_map_name                = string
    ssl_certificates            = list(string) # Names of managed SSL certificates
    http_keep_alive_timeout_sec = optional(number, 100)
    quic_override               = optional(string, "NONE")
  }))
  default = []
}

variable "http_proxies" {
  description = "HTTP proxy configurations"
  type = list(object({
    name         = string
    url_map_name = string
  }))
  default = []
}

variable "http_forwarding_rules" {
  description = "HTTP forwarding rule configurations"
  type = list(object({
    name                  = string
    target_proxy_name     = string
    ip_address_name       = optional(string)
    port_range            = optional(string, "443")
    is_https              = optional(bool, true)
    load_balancing_scheme = optional(string, "EXTERNAL_MANAGED")
    labels                = optional(map(string), {})
  }))
  default = []
}

variable "health_checks" {
  description = "Health check configurations for HTTP(S) LB"
  type = list(object({
    name                = string
    check_interval_sec  = optional(number, 10)
    timeout_sec         = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 3)
    port                = optional(number, 80)
    request_path        = optional(string, "/")
    proxy_header        = optional(string, "NONE")
    enable_logging      = optional(bool, false)
  }))
  default = []
}

# Internal Load Balancer Configuration
variable "internal_load_balancer_enabled" {
  description = "Enable internal load balancer"
  type        = bool
  default     = false
}

variable "internal_backend_services" {
  description = "Internal backend service configurations"
  type = list(object({
    name          = string
    region        = string
    protocol      = string
    network       = string
    timeout_sec   = optional(number, 30)
    network_tier  = optional(string, "PREMIUM")
    health_checks = optional(list(string), [])
    backends = optional(list(object({
      group          = string
      balancing_mode = optional(string, "CONNECTION")
    })), [])
  }))
  default = []
}

variable "internal_health_checks" {
  description = "Health check configurations for Internal LB"
  type = list(object({
    name           = string
    region         = string
    port           = optional(number, 80)
    request_path   = optional(string, "/")
    enable_logging = optional(bool, false)
  }))
  default = []
}

variable "internal_forwarding_rules" {
  description = "Internal forwarding rule configurations"
  type = list(object({
    name                 = string
    region               = string
    backend_service_name = string
    network              = string
    subnetwork           = string
    ports                = optional(list(string), ["80"])
  }))
  default = []
}

# Serverless NEG Configuration
variable "serverless_negs" {
  description = "Configuration for serverless NEGs (Cloud Run, Cloud Functions, App Engine)"
  type = object({
    cloud_run = optional(map(object({
      service_name = string
      region       = optional(string)
    })), {})
    cloud_functions = optional(map(object({
      function_name = string
      region        = optional(string)
    })), {})
    app_engine = optional(map(object({
      service = string
    })), {})
  })
  default = {
    cloud_run       = {}
    cloud_functions = {}
    app_engine      = {}
  }
}

variable "backend_neg_mappings" {
  description = "Map backend service names to their serverless NEG sources (type/key format)"
  type = map(object({
    type = string # "cloud_run", "cloud_function", or "app_engine"
    key  = string # The key from serverless_negs
  }))
  default = {}
}

