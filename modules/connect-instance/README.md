# Connect Instance Module

Creates and configures an AWS Connect instance with storage configuration and IAM roles.

## Features

- ✅ Connect instance creation
- ✅ Multiple identity management options (Connect, SAML, Directory)
- ✅ Storage configuration (S3, Kinesis)
- ✅ Contact flow logging
- ✅ Contact Lens integration
- ✅ Encryption support (KMS, AES256)

## Usage

### Basic Example

```hcl
module "connect_instance" {
  source = "../../modules/connect-instance"
  
  instance_alias           = "customer-support"
  identity_management_type = "CONNECT_MANAGED"
  
  inbound_calls_enabled  = true
  outbound_calls_enabled = false
  
  tags = {
    Environment = "production"
  }
}
```

### With S3 Storage

```hcl
module "connect_instance" {
  source = "../../modules/connect-instance"
  
  instance_alias           = "customer-support"
  identity_management_type = "CONNECT_MANAGED"
  
  storage_config = {
    call_recordings = {
      storage_type = "S3"
      s3_config = {
        bucket_name   = "my-connect-recordings"
        bucket_prefix = "recordings/"
        encryption_config = {
          encryption_type = "KMS"
          key_id          = "arn:aws:kms:us-east-1:123456789012:key/..."
        }
      }
    }
  }
}
```

### With SAML Authentication

```hcl
module "connect_instance" {
  source = "../../modules/connect-instance"
  
  instance_alias           = "enterprise-support"
  identity_management_type = "SAML"
  saml_metadata_url        = "https://portal.sso.us-east-1.amazonaws.com/saml/metadata/..."
  
  inbound_calls_enabled  = true
  outbound_calls_enabled = true
  
  contact_flow_logs_enabled = true
  contact_lens_enabled      = true
}
```

### With Directory Integration

```hcl
module "connect_instance" {
  source = "../../modules/connect-instance"
  
  instance_alias           = "corporate-support"
  identity_management_type = "EXISTING_DIRECTORY"
  directory_id             = "d-1234567890"
  
  inbound_calls_enabled = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| aws_connect_instance.this | resource |
| aws_connect_instance_storage_config.call_recordings | resource |
| aws_connect_instance_storage_config.chat_transcripts | resource |
| aws_connect_instance_storage_config.scheduled_reports | resource |
| aws_connect_instance_storage_config.attachments | resource |
| aws_connect_instance_storage_config.media_streams | resource |
| aws_caller_identity.current | data source |
| aws_region.current | data source |
| aws_partition.current | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_alias | Unique alias for the Connect instance | `string` | n/a | yes |
| identity_management_type | Identity management type | `string` | `"CONNECT_MANAGED"` | no |
| directory_id | AWS Directory Service directory ID | `string` | `null` | no |
| saml_metadata_url | SAML metadata URL | `string` | `null` | no |
| inbound_calls_enabled | Enable inbound calls | `bool` | `true` | no |
| outbound_calls_enabled | Enable outbound calls | `bool` | `false` | no |
| contact_flow_logs_enabled | Enable contact flow logs | `bool` | `true` | no |
| contact_lens_enabled | Enable Contact Lens | `bool` | `false` | no |
| early_media_enabled | Enable early media | `bool` | `true` | no |
| auto_resolve_best_voices | Auto-resolve best voices | `bool` | `true` | no |
| storage_config | Storage configuration | `any` | `{}` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | Connect instance ID |
| instance_arn | Connect instance ARN |
| instance_alias | Connect instance alias |
| instance_url | Connect admin URL |
| instance_status | Instance status |
| service_role_arn | Service role ARN |
| created_time | Instance creation timestamp |
| storage_config | Storage configuration details |
| features_enabled | Enabled features |
| connection_info | Connection information |

## Storage Types

### Supported Storage Resources

1. **call_recordings** - Store call recordings
2. **chat_transcripts** - Store chat transcripts
3. **scheduled_reports** - Store scheduled reports
4. **attachments** - Store file attachments from chats
5. **media_streams** - Store media streams

### Storage Options

#### S3 Storage

```hcl
storage_config = {
  call_recordings = {
    storage_type = "S3"
    s3_config = {
      bucket_name   = "recordings-bucket"
      bucket_prefix = "recordings/"
      encryption_config = {
        encryption_type = "KMS"  # or "AES256"
        key_id          = "arn:aws:kms:..."  # Required for KMS
      }
    }
  }
}
```

#### Kinesis Video Stream Storage

```hcl
storage_config = {
  call_recordings = {
    storage_type = "KINESIS_VIDEO_STREAM"
    kinesis_config = {
      prefix                 = "recordings"
      retention_period_hours = 24
      encryption_config = {
        encryption_type = "KMS"
        key_id          = "arn:aws:kms:..."
      }
    }
  }
}
```

## Identity Management Types

### CONNECT_MANAGED

Simplest option. Connect manages user identities.

**Pros:**
- Easy setup
- No external dependencies
- Good for small teams

**Cons:**
- No SSO
- Manual user management
- Limited integration

### SAML

Enterprise SSO with SAML 2.0.

**Pros:**
- Centralized identity management
- MFA support
- Audit trail
- Integration with existing IdP

**Cons:**
- Requires SAML IdP setup
- More complex configuration

**Supported IdPs:**
- AWS SSO
- Okta
- Azure AD
- OneLogin
- Google Workspace

### EXISTING_DIRECTORY

Integrate with AWS Directory Service.

**Pros:**
- Use existing Active Directory
- Familiar for IT teams
- Windows authentication

**Cons:**
- Requires AWS Directory Service
- Additional costs

**Supported Directory Types:**
- AWS Managed Microsoft AD
- AD Connector
- Simple AD

## Features

### Contact Flow Logs

When enabled, logs are sent to CloudWatch Logs:
- Log group: `/aws/connect/[instance_alias]`
- Retention: Configurable (default: 30 days)
- Use for: Debugging flows, monitoring

### Contact Lens

AI-powered analytics:
- Real-time sentiment analysis
- Call categorization
- Supervisor alerts
- Compliance monitoring

**Cost:** ~$0.015/minute analyzed

### Early Media

Allows audio before call is answered:
- Ring-back tones
- Prompts while routing
- Music on hold

## Cost Considerations

### Instance Costs

- **Per-use pricing**: $0.018/minute for voice
- **No upfront costs**
- **No minimum commitments**

### Storage Costs

#### S3 Storage
- **Standard**: ~$0.023/GB/month
- **Glacier**: ~$0.004/GB/month (for archives)

#### Kinesis Video Streams
- **Ingestion**: $0.0085/GB
- **Storage**: $0.023/GB/month
- **Retrieval**: $0.008/GB

### Contact Lens
- **Analysis**: $0.015/minute
- **Post-call**: Same rate
- **Real-time**: Same rate

## Security

### Encryption

**S3 Encryption:**
- SSE-S3 (AES-256)
- SSE-KMS (Customer managed keys)

**Kinesis Encryption:**
- KMS encryption required

### IAM

Service-linked role created automatically:
- `AWSServiceRoleForAmazonConnect`
- Required permissions granted

### Network

- **TLS 1.2+** for all connections
- **Regional endpoints** only
- **VPC endpoints** (future support)

## Compliance

### Supported Frameworks
- PCI DSS
- HIPAA
- GDPR
- SOC 1/2/3
- ISO 27001

### Requirements

1. Enable encryption (KMS recommended)
2. Enable logging
3. Set appropriate retention policies
4. Use SAML or Directory auth (not CONNECT_MANAGED)
5. Regular audits via CloudTrail

## Examples

See the [examples](../../examples/) directory for complete examples:
- [Minimal](../../examples/minimal/) - Basic setup
- [Standard](../../examples/standard/) - Typical deployment (Coming soon)
- [Enterprise](../../examples/enterprise/) - Full-featured (Coming soon)

## Troubleshooting

### Instance Creation Fails

**Error:** "Instance alias already exists"
**Solution:** Choose a different alias. Aliases are globally unique per account.

**Error:** "Directory not found"
**Solution:** Verify directory_id is correct and in the same region.

### Storage Configuration Fails

**Error:** "Bucket not found"
**Solution:** Create S3 bucket before applying module.

**Error:** "Access denied"
**Solution:** Ensure bucket policy allows Connect to write:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "connect.amazonaws.com"
  },
  "Action": ["s3:PutObject", "s3:PutObjectAcl"],
  "Resource": "arn:aws:s3:::bucket-name/*"
}
```

## Links

- [AWS Connect Documentation](https://docs.aws.amazon.com/connect/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/connect_instance)
- [Module Issues](https://github.com/infrakraft/terraform-aws-connect-contact-center/issues)