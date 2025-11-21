variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "custom_bucket_name" {
  description = "Custom bucket name. If empty, will be generated"
  type        = string
  default     = ""
}

variable "bucket_name_suffix" {
  description = "Suffix for the bucket name"
  type        = string
  default     = "data"
}

variable "location" {
  description = "Bucket location (region or multi-region)"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "Allow deletion of bucket with objects"
  type        = bool
  default     = false
}

variable "public_access_prevention" {
  description = "Public access prevention setting (inherited or enforced)"
  type        = string
  default     = "enforced"
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access"
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
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
  }))
  default = []
}

variable "encryption_key" {
  description = "KMS key for bucket encryption"
  type        = string
  default     = null
}

variable "log_bucket" {
  description = "Bucket for access logs"
  type        = string
  default     = null
}

variable "log_object_prefix" {
  description = "Prefix for log objects"
  type        = string
  default     = ""
}

variable "retention_policy" {
  description = "Retention policy configuration"
  type = object({
    is_locked        = bool
    retention_period = number
  })
  default = null
}

variable "cors_rules" {
  description = "CORS rules"
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website" {
  description = "Website configuration"
  type = object({
    main_page_suffix = optional(string)
    not_found_page   = optional(string)
  })
  default = null
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "iam_bindings" {
  description = "IAM role bindings (authoritative)"
  type = list(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = []
}

variable "iam_members" {
  description = "IAM members (additive)"
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}

variable "notifications" {
  description = "Pub/Sub notification configurations"
  type = list(object({
    topic              = string
    payload_format     = string
    event_types        = optional(list(string))
    custom_attributes  = optional(map(string))
    object_name_prefix = optional(string)
  }))
  default = []
}
