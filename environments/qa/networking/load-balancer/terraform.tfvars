# Terraform Variables for qa Load Balancer

project_id = "coderabbit-qa"
region     = "us-central1"

common_tags = {
  managed_by  = "terraform"
  environment = "qa"
}

# Remote State Configuration (optional)
enable_remote_state = false # Set to true if you want to fetch outputs from remote state
remote_state_bucket = "cr-terraform-state-qa"

# Serverless NEG Configuration
# Define all serverless backends that need NEGs
serverless_negs = {
  # Cloud Run services
  cloud_run = {
    "coderabbit_handler" = { service_name = "coderabbit-handler" }
    "pr_reviewer_saas"   = { service_name = "pr-reviewer-saas" }
    "token_service"      = { service_name = "token-service" }
    "db_api_server"      = { service_name = "db-api-server" }
    "sandboxer"          = { service_name = "sandboxer" }
  }

  # Cloud Functions
  cloud_functions = {
    "billingfunction"  = { function_name = "billingfunction" }
    "chargebeehandler" = { function_name = "chargebeehandler" }
  }

  # App Engine services
  app_engine = {
    "default" = { service = "default" }
  }
}

# Backend Service to NEG Mappings
# Maps each backend service to its corresponding serverless NEG
backend_service_mappings = {
  "coderabbit-handler-qa" = { type = "cloud_run", key = "coderabbit_handler" }
  "coderabbit-ui-qa"      = { type = "app_engine", key = "default" }
  "token-service-qa"      = { type = "cloud_run", key = "token_service" }
  "pr-reviewer-saas-qa"   = { type = "cloud_run", key = "pr_reviewer_saas" }
  "default-qa"            = { type = "cloud_run", key = "default-page-for-pr-reviewer" }
  "billingfunction-qa"    = { type = "cloud_function", key = "billingfunction" }
}

# Enable global load balancer
global_load_balancer_enabled = true

# Static IP Addresses
static_ip_addresses = [
  {
    name         = "coderabbit-qa-https"
    address_type = "EXTERNAL"
    labels = {
      managed-by-cnrm = "true"
      environment     = "qa"
    }
  },
  {
    name         = "api-qa-https"
    address_type = "EXTERNAL"
    labels = {
      managed-by-cnrm = "true"
      environment     = "qa"
    }
  }
]

# Managed SSL Certificates
managed_ssl_certificates = [
  {
    name    = "coderabbit-qawolf-alb-certificate"
    domains = ["app-qawolf.coderabbit.ai"]
  },
  {
    name    = "api-qawolf-certificate"
    domains = ["api-qawolf.coderabbit.ai"]
  }
]

# Security Policies
security_policies = [
  { name = "security-policy-handler-qa", enable_layer7_ddos = false },
  { name = "security-policy-ui-qa", enable_layer7_ddos = false },
  { name = "security-policy-billing-qa", enable_layer7_ddos = false },
  { name = "security-policy-token-qa", enable_layer7_ddos = false }
]

# Enable HTTP(S) load balancer
http_load_balancer_enabled = true
https_enabled              = true

# Backend Services
# Updated to match dev environment configuration (2025-11-03)
http_backend_services = [
  {
    name                            = "coderabbit-handler-qa"
    protocol                        = "HTTPS"
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    port_name                       = "http"
    timeout_sec                     = 30
    connection_draining_timeout_sec = 0
    locality_lb_policy              = "ROUND_ROBIN"
    session_affinity                = "NONE"
    enable_logging                  = true
    log_sample_rate                 = 0
    security_policy                 = "security-policy-handler-qa"
    backends                        = [] # Add backends when Cloud Run services are deployed
  },
  {
    name                            = "coderabbit-ui-qa"
    protocol                        = "HTTPS"
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    port_name                       = "http"
    timeout_sec                     = 30
    connection_draining_timeout_sec = 0
    locality_lb_policy              = "ROUND_ROBIN"
    session_affinity                = "NONE"
    enable_logging                  = true
    log_sample_rate                 = 0
    custom_response_headers = [
      "Content-Security-Policy:default-src * data: blob: 'unsafe-inline' 'unsafe-eval';",
      "X-Content-Type-Options:nosniff",
      "X-Frame-Options:SAMEORIGIN"
    ]
    backends = [] # Add backends when Cloud Run services are deployed
  },
  {
    name                            = "billingfunction-qa"
    description                     = "This is billing function v2"
    protocol                        = "HTTPS"
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    port_name                       = "http"
    timeout_sec                     = 30
    connection_draining_timeout_sec = 0
    locality_lb_policy              = "ROUND_ROBIN"
    session_affinity                = "NONE"
    enable_logging                  = true
    log_sample_rate                 = 0
    security_policy                 = "security-policy-billing-qa"
    backends                        = [] # Add backends when Cloud Run services are deployed
  },
  {
    name                            = "token-service-qa"
    protocol                        = "HTTPS"
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    port_name                       = "http"
    timeout_sec                     = 30
    connection_draining_timeout_sec = 0
    locality_lb_policy              = "ROUND_ROBIN"
    session_affinity                = "NONE"
    enable_cdn                      = true
    enable_logging                  = true
    log_sample_rate                 = 1
    security_policy                 = "security-policy-token-qa"
    cdn_policy = {
      cache_mode                   = "CACHE_ALL_STATIC"
      client_ttl                   = 3600
      default_ttl                  = 3600
      max_ttl                      = 86400
      signed_url_cache_max_age_sec = 0
      cache_key_policy = {
        include_host         = true
        include_protocol     = true
        include_query_string = true
      }
    }
    backends = [] # Add backends when Cloud Run services are deployed
  },
  {
    name                            = "pr-reviewer-saas-qa"
    protocol                        = "HTTPS"
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    port_name                       = "http"
    timeout_sec                     = 30
    connection_draining_timeout_sec = 0
    locality_lb_policy              = "ROUND_ROBIN"
    session_affinity                = "NONE"
    enable_logging                  = true
    log_sample_rate                 = 0
    custom_response_headers = [
      "X-Content-Type-Options:nosniff"
    ]
    backends = [] # Add backends when Cloud Run services are deployed
  },
  {
    name                            = "default-qa"
    protocol                        = "HTTPS"
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    port_name                       = "http"
    timeout_sec                     = 30
    connection_draining_timeout_sec = 0
    locality_lb_policy              = "ROUND_ROBIN"
    session_affinity                = "NONE"
    enable_logging                  = true
    log_sample_rate                 = 0
    custom_response_headers = [
      "X-Content-Type-Options:nosniff"
    ]
    backends = [] # Add backends when Cloud Run services are deployed
  }
]

# URL Maps
url_maps = [
  {
    name            = "coderabbit-qa-alb"
    default_service = "coderabbit-ui-qa"
    host_rules = [
      {
        hosts        = ["app-qawolf.coderabbit.ai"]
        path_matcher = "path-matcher-1"
      }
    ]
    path_matchers = [
      {
        name            = "path-matcher-1"
        default_service = "coderabbit-ui-qa"
        path_rules = [
          # Handler service paths
          {
            service = "coderabbit-handler-qa"
            paths = [
              "/addRepositories",
              "/backend/service/cron",
              "/checkOrganizations",
              "/createOrganizations",
              "/deleteAccountInternal",
              "/extension/product-tier",
              "/fetchAllInstalls",
              "/fetchAnInstall",
              "/fetchRepositoriesForUserID",
              "/getInstalledRepos",
              "/getOrganizationsDetails",
              "/getReposSettings",
              "/getRepositories",
              "/githubHandler",
              "/gitlabHandler",
              "/handleAzureDevops",
              "/handleBitbucket",
              "/jiraHandler",
              "/linearHandler",
              "/mail_subscription",
              "/marketplaceHandler",
              "/metricsAllRepos",
              "/orgLevelSettings",
              "/organizationSettings",
              "/trpc/*",
              "/updateMergeFields",
              "/updateOrgLevelSettings",
              "/updateReposSettings",
              "/updateSeats",
              "/upgradePlan",
              "/vercel/*",
              "/webhook/referral-info"
            ]
          },
          # Billing function paths
          {
            service = "billingfunction-qa"
            paths = [
              "/changeSubscriptionPlan",
              "/chargebeeHandler",
              "/checkAndCreateUser",
              "/checkCustomer",
              "/checkUser",
              "/checkout",
              "/createCustomer",
              "/createPortalSession",
              "/createSubscriptions",
              "/createUser",
              "/createVercelSubscription",
              "/getAllPlans",
              "/getOrgEmail",
              "/restartTrialSubscription",
              "/subscriptionHistory",
              "/updateCustomer",
              "/updateOrgEmail",
              "/updateSubscriptionStatus",
              "/validateSubscription"
            ]
          },
          # Token service paths
          {
            service = "token-service-qa"
            paths = [
              "/generateInternalToken",
              "/health"
            ]
          }
        ]
      }
    ]
  },
  # HTTP to HTTPS redirect URL map
  {
    name        = "coderabbit-qa-fe-redirect"
    description = "Automatically generated HTTP to HTTPS redirect for qa"
    default_url_redirect = {
      https_redirect         = true
      redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
      strip_query            = false
    }
  },
  # API Load Balancer URL Map (pr-reviewer-saas-qa)
  {
    name            = "api-qa-alb"
    default_service = "pr-reviewer-saas-qa"
    host_rules = [
      {
        hosts        = ["api-qawolf.coderabbit.ai"]
        path_matcher = "api-path-matcher"
      }
    ]
    path_matchers = [
      {
        name            = "api-path-matcher"
        default_service = "default-qa"
        path_rules = [
          # PR Reviewer SaaS API paths
          {
            service = "pr-reviewer-saas-qa"
            paths = [
              "/api/openapi/",
              "/api/swagger",
              "/api/swagger/*",
              "/api/v1/*",
              "/health",
              "/health/*",
              "/stats/*",
              "/ws"
            ]
          },
          # Seat management paths (routed to handler)
          {
            service = "coderabbit-handler-qa"
            paths = [
              "/v1/seat/*",
              "/v1/seats/*"
            ]
          }
        ]
      }
    ]
  }
]

# HTTPS Proxies
https_proxies = [
  {
    name                        = "coderabbit-qa-alb-target-proxy"
    url_map_name                = "coderabbit-qa-alb"
    ssl_certificates            = ["coderabbit-qawolf-alb-certificate"]
    http_keep_alive_timeout_sec = 100
    quic_override               = "NONE"
  },
  {
    name                        = "api-qa-target-proxy"
    url_map_name                = "api-qa-alb"
    ssl_certificates            = ["api-qawolf-certificate"]
    http_keep_alive_timeout_sec = 100
    quic_override               = "NONE"
  }
]

# HTTP Proxies (for redirect)
http_proxies = [
  {
    name         = "coderabbit-qa-fe-target-proxy"
    url_map_name = "coderabbit-qa-fe-redirect"
  }
]

# Forwarding Rules
http_forwarding_rules = [
  # HTTPS forwarding rule (port 443)
  {
    name                  = "coderabbit-qa-alb-fe"
    target_proxy_name     = "coderabbit-qa-alb-target-proxy"
    ip_address_name       = "coderabbit-qa-https"
    port_range            = "443"
    is_https              = true
    load_balancing_scheme = "EXTERNAL_MANAGED"
    labels = {
      managed-by-cnrm = "true"
      environment     = "qa"
    }
  },
  # HTTP forwarding rule (port 80) - redirect to HTTPS
  {
    name                  = "coderabbit-qa-fe-forwarding-rule"
    target_proxy_name     = "coderabbit-qa-fe-target-proxy"
    ip_address_name       = "coderabbit-qa-https"
    port_range            = "80"
    is_https              = false
    load_balancing_scheme = "EXTERNAL_MANAGED"
    labels = {
      managed-by-cnrm = "true"
      environment     = "qa"
    }
  },
  # API Load Balancer forwarding rule (port 443)
  {
    name                  = "api-qa-alb-fe"
    target_proxy_name     = "api-qa-target-proxy"
    ip_address_name       = "api-qa-https"
    port_range            = "443"
    is_https              = true
    load_balancing_scheme = "EXTERNAL_MANAGED"
    labels = {
      managed-by-cnrm = "true"
      environment     = "qa"
    }
  }
]

# Health Checks (if needed)
health_checks = []

# Internal Load Balancer (disabled for qa)
internal_load_balancer_enabled = false
internal_backend_services      = []
internal_health_checks         = []
internal_forwarding_rules      = []