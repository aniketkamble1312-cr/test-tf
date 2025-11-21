# GCS QA Outputs

output "buckets" {
  description = "Created GCS buckets"
  value = {
    for k, v in module.gcs_buckets : k => {
      bucket_name          = v.bucket_name
      bucket_url           = v.bucket_url
      bucket_self_link     = v.bucket_self_link
      bucket_location      = v.bucket_location
      bucket_storage_class = v.bucket_storage_class
    }
  }
}

