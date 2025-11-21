project_id  = "coderabbit-qa"
environment = "qa"

common_tags = {
  environment = "qa"
  managedby   = "terraform"
  team        = "sre"
}

buckets = [
  {
    bucket_key                  = "coderabbit-reviewer-data-store-qa"
    custom_bucket_name          = "coderabbit-reviewer-data-store-qa"
    bucket_name_suffix          = "coderabbit-reviewer-data-store-qa"
    location                    = "US"
    storage_class               = "STANDARD"
    public_access_prevention    = "enforced"
    uniform_bucket_level_access = true
    versioning_enabled          = true
    lifecycle_rules = [
      {
        action = {
          type = "Delete"
        }
        condition = {
          with_state         = "ARCHIVED"
          num_newer_versions = 2
        }
      },
      {
        action = {
          type = "Delete"
        }
        condition = {
          days_since_noncurrent_time = 1
        }
      }
    ]
    soft_delete_policy = {
      retention_duration_seconds = 604800
    }
  },
  {
    bucket_key                  = "cr-cache-qa"
    custom_bucket_name          = "cr-cache-qa"
    bucket_name_suffix          = "cr-cache-qa"
    location                    = "US-CENTRAL1"
    storage_class               = "STANDARD"
    public_access_prevention    = "enforced"
    uniform_bucket_level_access = true
    versioning_enabled          = false
    lifecycle_rules = [
      {
        action = {
          type = "Delete"
        }
        condition = {
          age = 7
        }
      }
    ]
    soft_delete_policy = {
      retention_duration_seconds = 0
    }
  },
  {
    bucket_key                  = "run-sources-coderabbit-qa-us-central1"
    custom_bucket_name          = "run-sources-coderabbit-qa-us-central1"
    bucket_name_suffix          = "run-sources-coderabbit-qa-us-central1"
    location                    = "US-CENTRAL1"
    storage_class               = "STANDARD"
    public_access_prevention    = "inherited"
    uniform_bucket_level_access = true
    versioning_enabled          = true
    lifecycle_rules = [
      {
        action = {
          type = "Delete"
        }
        condition = {
          with_state         = "ARCHIVED"
          num_newer_versions = 3
        }
      }
    ]
    cors_rules = [
      {
        origin = [
          "https://*.cloud.google.com",
          "https://*.corp.google.com",
          "https://*.corp.google.com:*",
          "https://*.cloud.google",
          "https://*.byoid.goog"
        ]
        method = [
          "GET"
        ]
      }
    ]
    soft_delete_policy = {
      retention_duration_seconds = 604800
    }
    labels = {
      goog-managed-by = "cloudfunctions"
    }
  },
  {
    bucket_key                  = "test-bucket-qa"
    custom_bucket_name          = "test-bucket-qa"
    bucket_name_suffix          = "test-bucket-qa"
    location                    = "US-CENTRAL1"
    storage_class               = "STANDARD"
    public_access_prevention    = "enforced"
    uniform_bucket_level_access = true
    versioning_enabled          = false
    soft_delete_policy = {
      retention_duration_seconds = 86400
    }
  }
]