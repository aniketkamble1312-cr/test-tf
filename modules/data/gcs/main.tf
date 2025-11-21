# Google Cloud Storage Module
# Creates and manages GCS buckets with lifecycle policies and IAM

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

locals {
  bucket_name = var.custom_bucket_name != "" ? var.custom_bucket_name : "${var.project_id}-${var.environment}-${var.bucket_name_suffix}"
}

resource "google_storage_bucket" "bucket" {
  name                        = local.bucket_name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  force_destroy               = var.force_destroy
  public_access_prevention    = var.public_access_prevention
  uniform_bucket_level_access = var.uniform_bucket_level_access

  # Versioning
  dynamic "versioning" {
    for_each = var.versioning_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Lifecycle rules
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state                 = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class      = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        matches_prefix             = lookup(lifecycle_rule.value.condition, "matches_prefix", null)
        matches_suffix             = lookup(lifecycle_rule.value.condition, "matches_suffix", null)
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        days_since_custom_time     = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
      }
    }
  }

  # Encryption
  dynamic "encryption" {
    for_each = var.encryption_key != null ? [1] : []
    content {
      default_kms_key_name = var.encryption_key
    }
  }

  # Logging
  dynamic "logging" {
    for_each = var.log_bucket != null ? [1] : []
    content {
      log_bucket        = var.log_bucket
      log_object_prefix = var.log_object_prefix
    }
  }

  # Retention policy
  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [1] : []
    content {
      is_locked        = var.retention_policy.is_locked
      retention_period = var.retention_policy.retention_period
    }
  }

  # CORS
  dynamic "cors" {
    for_each = var.cors_rules
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = lookup(cors.value, "response_header", null)
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
    }
  }

  # Website
  dynamic "website" {
    for_each = var.website != null ? [1] : []
    content {
      main_page_suffix = lookup(var.website, "main_page_suffix", null)
      not_found_page   = lookup(var.website, "not_found_page", null)
    }
  }

  # Labels
  labels = merge(
    var.labels,
    {
      environment = var.environment
      managed_by  = "terraform"
    }
  )
}

# IAM bindings
resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = { for binding in var.iam_bindings : binding.role => binding }

  bucket  = google_storage_bucket.bucket.name
  role    = each.value.role
  members = each.value.members

  dynamic "condition" {
    for_each = lookup(each.value, "condition", null) != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# IAM members (additive)
resource "google_storage_bucket_iam_member" "members" {
  for_each = {
    for pair in flatten([
      for binding in var.iam_members : [
        for member in binding.members : {
          role   = binding.role
          member = member
          key    = "${binding.role}-${member}"
        }
      ]
    ]) : pair.key => pair
  }

  bucket = google_storage_bucket.bucket.name
  role   = each.value.role
  member = each.value.member
}

# Notification configuration
resource "google_storage_notification" "notification" {
  for_each = { for notif in var.notifications : notif.topic => notif }

  bucket             = google_storage_bucket.bucket.name
  payload_format     = each.value.payload_format
  topic              = each.value.topic
  event_types        = lookup(each.value, "event_types", null)
  custom_attributes  = lookup(each.value, "custom_attributes", null)
  object_name_prefix = lookup(each.value, "object_name_prefix", null)
}
