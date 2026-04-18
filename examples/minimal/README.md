# Minimal Connect Instance Example

This example creates a basic AWS Connect instance with minimal configuration.

## Features

- ✅ Connect instance with CONNECT_MANAGED identity
- ✅ Inbound calls enabled
- ✅ Contact flow logging enabled
- ✅ S3 bucket for call recordings (optional)
- ✅ Automatic lifecycle management

## What Gets Created

1. **AWS Connect Instance**
   - Instance alias: configurable
   - Identity management: CONNECT_MANAGED
   - Inbound calls: Enabled
   - Outbound calls: Disabled

2. **S3 Bucket** (if enabled)
   - Call recordings storage
   - Public access blocked
   - Versioning enabled
   - AES-256 encryption
   - 90-day lifecycle policy

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- AWS Provider >= 5.0
- Appropriate AWS permissions

## Quick Start

### 1. Copy Configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Configuration

```bash
nano terraform.tfvars
```

Update these values:
```hcl
instance_alias = "your-unique-alias"
aws_region     = "us-east-1"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Plan

```bash
terraform plan
```

### 5. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 6. Get Outputs

```bash
terraform output
```

## Usage

### Access Admin Interface

```bash
# Get admin URL
terraform output admin_url

# Output: https://your-alias.my.connect.aws
```

Login with:
- Username: admin
- Password: (set during first login)

### Access Contact Control Panel (CCP)

```bash
# Get CCP URL
terraform output ccp_url

# Output: https://your-alias.my.connect.aws/ccp-v2/
```

Agents use this URL to handle calls.

## Customization

### Disable Call Recordings

```hcl
# terraform.tfvars
enable_call_recordings = false
```

### Change Retention Period

```hcl
# terraform.tfvars
recordings_retention_days = 30  # 30 days instead of 90
```

### Add More Tags

```hcl
# terraform.tfvars
tags = {
  Environment = "production"
  Project     = "CustomerSupport"
  Team        = "Support"
  Owner       = "john.doe@example.com"
}
```

## Cost Estimate

### Monthly Costs (Approximate)

**AWS Connect:**
- 1,000 minutes: ~$18
- 10,000 minutes: ~$180
- 100,000 minutes: ~$1,800

**S3 Storage (Call Recordings):**
- 10 GB: ~$0.23
- 100 GB: ~$2.30
- 1 TB: ~$23

**Total for 10,000 minutes + 100GB:**
- ~$182/month

## Testing

### Create Test Flow

1. Login to admin interface
2. Go to "Routing" → "Contact Flows"
3. Create new flow
4. Add "Play prompt" block
5. Save and publish

### Test with Softphone

1. Open CCP URL
2. Set status to "Available"
3. Call test number (provided in console)

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes'
```

**Warning:** This will delete:
- Connect instance
- S3 bucket and all recordings
- All configuration

## Troubleshooting

### Instance Creation Fails

**Error:** "Instance alias already in use"

**Solution:** The alias must be unique across your AWS account. Choose a different alias.

### S3 Bucket Policy Error

**Error:** "Access Denied"

**Solution:** Wait 30 seconds after bucket creation, then retry. IAM policies need time to propagate.

### Can't Access Admin URL

**Error:** "Instance not found"

**Solution:** Check instance status:
```bash
terraform output instance_status
```

Wait until status is "ACTIVE".

## Next Steps

1. **Add Users** - Create agents and supervisors
2. **Create Contact Flows** - Design your IVR
3. **Claim Phone Number** - Get a number to receive calls
4. **Add Queues** - Route calls to different teams
5. **Enable Metrics** - Set up CloudWatch dashboards

## Security Considerations

- ✅ S3 bucket public access blocked
- ✅ Encryption at rest (AES-256)
- ✅ Encryption in transit (TLS 1.2+)
- ⚠️ Using CONNECT_MANAGED auth (not recommended for production)

**For Production:**
- Use SAML authentication
- Enable KMS encryption
- Implement MFA
- Set up CloudTrail logging

## Examples

See other examples for advanced configurations:
- [Standard](../standard/) - Multi-queue setup (Coming soon)
- [Enterprise](../enterprise/) - Full production setup (Coming soon)

## Support

- [Module Documentation](../../README.md)
- [AWS Connect Documentation](https://docs.aws.amazon.com/connect/)
- [Issue Tracker](https://github.com/infrakraft/terraform-aws-connect-contact-center/issues)