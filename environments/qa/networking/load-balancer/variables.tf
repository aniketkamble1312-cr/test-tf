# Variables for QA Load Balancer

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "credentials_file" {
  description = "Path to the GCP credentials file"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    managed_by  = "terraform"
    environment = "qa"
  }
}

# Load Balancer Configuration
variable "global_load_balancer_enabled" {
  description = "Enable global load balancer"
  type        = bool
  default     = true
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

variable "managed_ssl_certificates" {
  description = "List of managed SSL certificates to create"
  type = list(object({
    name    = string
    domains = list(string)
  }))
  default = []
}

variable "security_policies" {
  description = "List of security policies to create"
  type = list(object({
    name               = string
    enable_layer7_ddos = optional(bool, false)
  }))
  default = []
}

variable "http_load_balancer_enabled" {
  description = "Enable HTTP(S) load balancer"
  type        = bool
  default     = true
}

variable "https_enabled" {
  description = "Enable HTTPS (SSL/TLS)"
  type        = bool
  default     = true
}

variable "http_backend_services" {
  description = "HTTP backend service configurations"
  type        = any
  default     = []
}

variable "url_maps" {
  description = "URL map configurations"
  type        = any
  default     = []
}

variable "https_proxies" {
  description = "HTTPS proxy configurations"
  type = list(object({
    name                        = string
    url_map_name                = string
    ssl_certificates            = list(string)
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
  type        = any
  default     = []
}

variable "internal_load_balancer_enabled" {
  description = "Enable internal load balancer"
  type        = bool
  default     = false
}

variable "internal_backend_services" {
  description = "Internal backend service configurations"
  type        = any
  default     = []
}

variable "internal_health_checks" {
  description = "Health check configurations for Internal LB"
  type        = any
  default     = []
}

variable "internal_forwarding_rules" {
  description = "Internal forwarding rule configurations"
  type        = any
  default     = []
}

# Serverless Backend Configuration
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

variable "backend_service_mappings" {
  description = "Map backend service names to their serverless NEG sources"
  type = map(object({
    type = string # "cloud_run", "cloud_function", or "app_engine"
    key  = string # The key from serverless_negs
  }))
  default = {}
}

variable "remote_state_bucket" {
  description = "GCS bucket for remote state"
  type        = string
  default     = ""
}

variable "enable_remote_state" {
  description = "Enable remote state data sources for compute services"
  type        = bool
  default     = false
}
