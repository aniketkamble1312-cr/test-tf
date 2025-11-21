# GCS (Google Cloud Storage) Buckets

This component manages Google Cloud Storage buckets for the QA environment.

## Overview

GCS buckets are used for:
- Application data storage
- Backup storage
- Log storage
- Temporary file storage
- Cloud Run source code storage

## Quick Start

```bash
cd environments/qa/data/gcs
terraform init
terraform plan
terraform apply
```

## Configuration

### Variables

Configuration is done through `terraform.tfvars`. Key variables:

- `project_id`: GCP project ID (default: `coderabbit-qa`)
- `environment`: Environment name (default: `qa`)
- `common_tags`: Common labels applied to all buckets
- `buckets`: List of bucket configurations

### Bucket Configuration

Each bucket in the `buckets` list supports the following options:

```hcl
{
  bucket_key                  = "unique-bucket-key"        # Required: Unique identifier
  custom_bucket_name          = "my-bucket-name"          # Optional: Custom bucket name
  bucket_name_suffix          = "my-bucket-suffix"        # Required: Bucket name suffix
  location                    = "US-CENTRAL1"             # Required: Bucket location
  storage_class               = "STANDARD"                # Optional: Storage class
  public_access_prevention    = "enforced"                # Optional: Public access setting
  uniform_bucket_level_access = true                      # Optional: Enable UBLA
  versioning_enabled          = false                     # Optional: Enable versioning
  force_destroy               = false                     # Optional: Allow force destroy
  
  # Lifecycle rules
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 30  # Delete objects older than 30 days
      }
    }
  ]
  
  # Soft delete policy
  soft_delete_policy = {
    retention_duration_seconds = 86400  # 1 day
  }
  
  # CORS rules (for web access)
  cors_rules = [
    {
      origin = ["https://example.com"]
      method = ["GET", "POST"]
      response_header = ["Content-Type"]
      max_age_seconds = 3600
    }
  ]
  
  # Custom labels
  labels = {
    purpose = "application-data"
  }
}
```

## Examples

### Simple Storage Bucket

```hcl
{
  bucket_key                  = "app-data-qa"
  custom_bucket_name          = "app-data-qa"
  bucket_name_suffix          = "app-data-qa"
  location                    = "US-CENTRAL1"
  storage_class               = "STANDARD"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning_enabled          = false
}
```

### Versioned Bucket with Lifecycle Rules

```hcl
{
  bucket_key                  = "backup-qa"
  custom_bucket_name          = "backup-qa"
  bucket_name_suffix          = "backup-qa"
  location                    = "US"
  storage_class               = "STANDARD"
  versioning_enabled          = true
  lifecycle_rules = [
    {
      action = { type = "Delete" }
      condition = {
        with_state         = "ARCHIVED"
        num_newer_versions = 3
      }
    }
  ]
  soft_delete_policy = {
    retention_duration_seconds = 604800  # 7 days
  }
}
```

### Cache Bucket with Auto-Delete

```hcl
{
  bucket_key                  = "cache-qa"
  custom_bucket_name          = "cache-qa"
  bucket_name_suffix          = "cache-qa"
  location                    = "US-CENTRAL1"
  storage_class               = "STANDARD"
  versioning_enabled          = false
  lifecycle_rules = [
    {
      action = { type = "Delete" }
      condition = {
        age = 7  # Delete after 7 days
      }
    }
  ]
  soft_delete_policy = {
    retention_duration_seconds = 0  # No soft delete
  }
}
```

## Common Operations

### Add a New Bucket

1. Edit `terraform.tfvars`
2. Add a new bucket configuration to the `buckets` list
3. Run `terraform plan` to preview changes
4. Run `terraform apply` to create the bucket

### Modify Bucket Configuration

1. Edit the bucket configuration in `terraform.tfvars`
2. Run `terraform plan` to see what will change
3. Run `terraform apply` to apply changes

**Note**: Some changes (like location) cannot be modified after creation.

### Delete a Bucket

1. Remove the bucket from `terraform.tfvars`
2. Run `terraform plan` to preview deletion
3. Run `terraform apply` to delete

**Warning**: Ensure `force_destroy = true` if the bucket contains objects, or manually empty the bucket first.

### Import Existing Bucket

If a bucket already exists in GCP:

1. Create an `import.tf` file:
   ```hcl
   import {
     to = module.gcs_buckets["bucket-key"]
     id = "coderabbit-qa/bucket-name"
   }
   ```

2. Add the bucket configuration to `terraform.tfvars`
3. Run `terraform plan` to verify
4. Run `terraform apply` to import
5. Remove `import.tf` after successful import

## Outputs

The module outputs bucket information:

- `bucket_names`: Map of bucket keys to bucket names
- `bucket_urls`: Map of bucket keys to bucket URLs
- `bucket_self_links`: Map of bucket keys to self links

View outputs:
```bash
terraform output
```

## Best Practices

1. **Naming**: Use descriptive, consistent naming (e.g., `app-data-qa`, `backup-qa`)
2. **Location**: Choose location based on data residency requirements
3. **Versioning**: Enable for critical data that needs recovery
4. **Lifecycle Rules**: Configure to manage costs (delete old objects)
5. **Access Control**: Always use `public_access_prevention = "enforced"` unless public access is required
6. **UBLA**: Enable `uniform_bucket_level_access` for simpler IAM management
7. **Soft Delete**: Configure appropriate retention for data recovery needs

## Troubleshooting

### Bucket Already Exists

**Error**: `Bucket already exists`

**Solution**: Import the existing bucket (see Import Existing Bucket above)

### Cannot Change Location

**Error**: `Location cannot be changed`

**Solution**: Location is immutable. Create a new bucket and migrate data.

### Permission Denied

**Error**: `Permission denied on bucket`

**Solution**: 
- Check IAM permissions: `gcloud projects get-iam-policy coderabbit-qa`
- Ensure you have Storage Admin role
- Verify service account permissions if using CI/CD

### Force Destroy Required

**Error**: `Bucket is not empty`

**Solution**: 
- Set `force_destroy = true` in bucket config, OR
- Manually empty the bucket: `gsutil rm -r gs://bucket-name/**`

## Related Components

- **IAM Service Accounts**: Buckets often need service account access
- **Cloud Run**: Uses buckets for source code storage
- **Cloud Functions**: May use buckets for function code

---

For more information, see the [GCS module documentation](../../../../modules/data/gcs/README.md).




