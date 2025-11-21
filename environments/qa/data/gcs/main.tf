# GCS Configuration for QA Environment

module "gcs_buckets" {
  for_each = { for idx, bucket in var.buckets : bucket.bucket_key => bucket }

  source = "../../../../modules/data/gcs"

  # Project and environment
  project_id  = var.project_id
  environment = var.environment

  # Bucket configuration
  custom_bucket_name          = lookup(each.value, "custom_bucket_name", "")
  bucket_name_suffix          = each.value.bucket_name_suffix
  location                    = lookup(each.value, "location", "US")
  storage_class               = lookup(each.value, "storage_class", "STANDARD")
  force_destroy               = lookup(each.value, "force_destroy", false)
  public_access_prevention    = lookup(each.value, "public_access_prevention", "enforced")
  uniform_bucket_level_access = lookup(each.value, "uniform_bucket_level_access", true)
  versioning_enabled          = lookup(each.value, "versioning_enabled", false)
  lifecycle_rules             = lookup(each.value, "lifecycle_rules", [])
  encryption_key              = lookup(each.value, "encryption_key", null)
  log_bucket                  = lookup(each.value, "log_bucket", null)
  log_object_prefix           = lookup(each.value, "log_object_prefix", "")
  retention_policy            = lookup(each.value, "retention_policy", null)
  cors_rules                  = lookup(each.value, "cors_rules", [])
  website                     = lookup(each.value, "website", null)
  labels                      = merge(var.common_tags, lookup(each.value, "labels", {}))
  iam_bindings                = lookup(each.value, "iam_bindings", [])
  iam_members                 = lookup(each.value, "iam_members", [])
  notifications               = lookup(each.value, "notifications", [])
}

