# Load Balancer

This component manages Google Cloud Load Balancers for the QA environment.

## Overview

Load balancers distribute traffic across multiple backend services.

## Quick Start

```bash
cd environments/qa/networking/load-balancer
terraform init
terraform plan
terraform apply
```

## Configuration

Configuration is in `terraform.tfvars`. Manages:
- HTTP(S) load balancers
- Backend services
- Health checks
- URL maps
- SSL certificates
- Forwarding rules

## Common Operations

### Create Load Balancer

1. Edit `terraform.tfvars`
2. Add load balancer configuration
3. Run `terraform plan`
4. Run `terraform apply`

### Update Backend Services

1. Edit backend service configuration
2. Run `terraform apply`

## Best Practices

1. **Health Checks**: Configure appropriate health check intervals
2. **Backend Services**: Use instance groups or NEGs
3. **SSL**: Use managed SSL certificates when possible
4. **CDN**: Enable CDN for static content

---

See `variables.tf` for detailed configuration options.




