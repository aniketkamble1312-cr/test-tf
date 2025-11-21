# GCS QA Variables

variable "project_id" {
  description = "The GCP project ID for the qa environment"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "qa"
}

variable "common_tags" {
  description = "Common tags to apply to all resources (GCS labels must be lowercase)"
  type        = map(string)
  default = {
    environment = "qa"
    managed_by  = "terraform"
    team        = "sre"
  }
}

variable "buckets" {
  description = "GCS buckets to create"
  type = list(object({
    bucket_key                  = string # Unique key for each bucket
    custom_bucket_name          = optional(string, "")
    bucket_name_suffix          = string
    location                    = optional(string, "US")
    storage_class               = optional(string, "STANDARD")
    force_destroy               = optional(bool, false)
    public_access_prevention    = optional(string, "enforced")
    uniform_bucket_level_access = optional(bool, true)
    versioning_enabled          = optional(bool, false)
    lifecycle_rules = optional(list(object({
      action = object({
        type          = string
        storage_class = optional(string)
      })
      condition = object({
        age                        = optional(number)
        created_before             = optional(string)
        with_state                 = optional(string)
        matches_storage_class      = optional(list(string))
        matches_prefix             = optional(list(string))
        matches_suffix             = optional(list(string))
        num_newer_versions         = optional(number)
        days_since_custom_time     = optional(number)
        days_since_noncurrent_time = optional(number)
      })
    })), [])
    encryption_key    = optional(string, null)
    log_bucket        = optional(string, null)
    log_object_prefix = optional(string, "")
    retention_policy = optional(object({
      is_locked        = bool
      retention_period = number
    }), null)
    cors_rules = optional(list(object({
      origin          = list(string)
      method          = list(string)
      response_header = optional(list(string))
      max_age_seconds = optional(number)
    })), [])
    website = optional(object({
      main_page_suffix = optional(string)
      not_found_page   = optional(string)
    }), null)
    labels = optional(map(string), {})
    iam_bindings = optional(list(object({
      role    = string
      members = list(string)
      condition = optional(object({
        title       = string
        description = string
        expression  = string
      }))
    })), [])
    iam_members = optional(list(object({
      role    = string
      members = list(string)
    })), [])
    notifications = optional(list(object({
      topic              = string
      payload_format     = string
      event_types        = optional(list(string))
      custom_attributes  = optional(map(string))
      object_name_prefix = optional(string)
    })), [])
  }))
  default = []
}

