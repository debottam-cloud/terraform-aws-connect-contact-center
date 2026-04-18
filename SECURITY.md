# Security Policy

## 🔒 Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow these steps:

### Do NOT:
- ❌ Open a public GitHub issue
- ❌ Discuss the vulnerability publicly
- ❌ Share details on social media

### DO:
- ✅ Email security@infrakraft.com
- ✅ Provide detailed information
- ✅ Allow reasonable time for a fix

### What to Include:

1. **Description** - What is the vulnerability?
2. **Impact** - What can an attacker do?
3. **Steps to Reproduce** - How can we verify it?
4. **Affected Versions** - Which versions are impacted?
5. **Suggested Fix** - If you have ideas (optional)

### Response Timeline:

- **24 hours** - Initial acknowledgment
- **7 days** - Initial assessment
- **30 days** - Fix and disclosure (if applicable)

## 🛡️ Security Best Practices

### AWS Connect Instance Security

#### Identity Management

**CONNECT_MANAGED (Basic)**
````hcl
module "contact_center" {
  source = "infrakraft/connect-contact-center/aws"
  
  instance_alias           = "my-center"
  identity_management_type = "CONNECT_MANAGED"
  
  # ⚠️ Least secure option
  # Use only for: Testing, small teams, non-production
}
````

**SAML (Recommended for Enterprise)**
````hcl
module "contact_center" {
  source = "infrakraft/connect-contact-center/aws"
  
  instance_alias           = "my-center"
  identity_management_type = "SAML"
  saml_metadata_url        = "https://sso.example.com/metadata"
  
  # ✅ Enterprise SSO
  # Benefits: MFA, centralized management, audit trail
}
````

**EXISTING_DIRECTORY (For Active Directory)**
````hcl
module "contact_center" {
  source = "infrakraft/connect-contact-center/aws"
  
  instance_alias           = "my-center"
  identity_management_type = "EXISTING_DIRECTORY"
  directory_id             = "d-1234567890"
  
  # ✅ Integrates with existing AD
  # Benefits: Existing identity infrastructure
}
````

#### Storage Encryption

**S3 Encryption (Required)**
````hcl
storage_config = {
  call_recordings = {
    storage_type = "S3"
    s3_config = {
      bucket_name   = "recordings-bucket"
      bucket_prefix = "recordings/"
      
      encryption_config = {
        # Option 1: AWS-managed encryption
        encryption_type = "AES256"
        
        # Option 2: Customer-managed KMS (Recommended)
        # encryption_type = "KMS"
        # key_id          = aws_kms_key.connect.arn
      }
    }
  }
}
````

**KMS Key Policy (Example)**
````hcl
resource "aws_kms_key" "connect" {
  description             = "Connect encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Connect to use the key"
        Effect = "Allow"
        Principal = {
          Service = "connect.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
````

### S3 Bucket Security

**Bucket Configuration**
````hcl
resource "aws_s3_bucket" "recordings" {
  bucket = "connect-recordings"
  
  tags = {
    Name        = "Connect Recordings"
    Environment = "production"
    DataClass   = "Confidential"  # Important for compliance
  }
}

# Block public access (CRITICAL)
resource "aws_s3_bucket_public_access_block" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning (for audit trail)
resource "aws_s3_bucket_versioning" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.connect.arn
    }
  }
}

# Lifecycle policy (compliance requirement)
resource "aws_s3_bucket_lifecycle_configuration" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  
  rule {
    id     = "delete-old-recordings"
    status = "Enabled"
    
    expiration {
      days = 90  # Adjust based on compliance requirements
    }
    
    noncurrent_version_expiration {
      days = 30
    }
  }
}

# Logging (for audit trail)
resource "aws_s3_bucket_logging" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access/"
}
````

### IAM Security

**Principle of Least Privilege**
````hcl
# ✅ GOOD: Specific permissions
resource "aws_iam_role_policy" "connect_s3_access" {
  name = "connect-s3-access"
  role = aws_iam_role.connect.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.recordings.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketAcl"
        ]
        Resource = aws_s3_bucket.recordings.arn
      }
    ]
  })
}

# ❌ BAD: Overly broad permissions
resource "aws_iam_role_policy" "connect_admin" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "*"  # TOO BROAD!
      Resource = "*"  # TOO BROAD!
    }]
  })
}
````

**Service Role Trust Policy**
````hcl
data "aws_iam_policy_document" "connect_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["connect.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
    
    # Optional: Restrict to specific instance
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_connect_instance.this.arn]
    }
  }
}
````

### Network Security

**VPC Integration (Future)**
````hcl
# Coming in future versions
# Connect instances don't currently support VPC endpoints
# But we'll add support when available
````

### Monitoring & Logging

**CloudWatch Logs**
````hcl
# Enable contact flow logs
contact_flow_logs_enabled = true

# Create log retention policy
resource "aws_cloudwatch_log_group" "connect_flows" {
  name              = "/aws/connect/${var.instance_alias}"
  retention_in_days = 90  # Compliance requirement
  
  kms_key_id = aws_kms_key.logs.arn
}
````

**CloudTrail Monitoring**
````hcl
# Monitor API calls
resource "aws_cloudtrail" "connect" {
  name                          = "connect-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::Connect::Instance"
      values = ["arn:aws:connect:*:${data.aws_caller_identity.current.account_id}:instance/*"]
    }
  }
}
````

## 🔐 Compliance Considerations

### PCI DSS (Payment Card Industry)

If handling payment card data:

1. **Enable Call Recording Encryption**
````hcl
   encryption_config = {
     encryption_type = "KMS"
     key_id          = aws_kms_key.pci_compliant.arn
   }
````

2. **Set Retention Policies**
   - Store recordings only as long as needed
   - Maximum 90 days recommended

3. **Access Controls**
   - MFA required for access
   - Audit all access to recordings

4. **Network Segmentation**
   - Use dedicated AWS account for PCI workloads
   - Implement strict IAM policies

### HIPAA (Health Insurance Portability and Accountability Act)

If handling Protected Health Information (PHI):

1. **Sign AWS BAA** - Business Associate Agreement
2. **Enable Encryption**
   - At rest (S3, CloudWatch)
   - In transit (TLS)
3. **Audit Logging**
   - CloudTrail enabled
   - Log retention ≥ 6 years
4. **Access Controls**
   - Role-based access
   - MFA required

### GDPR (General Data Protection Regulation)

For EU data:

1. **Data Location**
````hcl
   # Use EU region
   provider "aws" {
     region = "eu-west-1"  # Ireland
   }
````

2. **Data Retention**
````hcl
   # Auto-delete old data
   lifecycle_configuration {
     rule {
       expiration {
         days = 30  # Right to be forgotten
       }
     }
   }
````

3. **Data Portability**
   - Enable data export features
   - Document data storage locations

## 🚨 Security Checklist

Before deploying to production:

- [ ] **Identity Management**
  - [ ] SAML or AD integration configured
  - [ ] MFA enabled for all users
  - [ ] Password policy enforced

- [ ] **Encryption**
  - [ ] S3 buckets encrypted (KMS preferred)
  - [ ] CloudWatch logs encrypted
  - [ ] KMS key rotation enabled

- [ ] **Access Control**
  - [ ] IAM roles follow least privilege
  - [ ] S3 buckets have public access blocked
  - [ ] Resource policies reviewed

- [ ] **Monitoring**
  - [ ] CloudTrail enabled
  - [ ] Contact flow logs enabled
  - [ ] CloudWatch alarms configured
  - [ ] Log retention policies set

- [ ] **Compliance**
  - [ ] Required compliance frameworks identified
  - [ ] Appropriate controls implemented
  - [ ] Regular audits scheduled

- [ ] **Backup & DR**
  - [ ] S3 versioning enabled
  - [ ] Cross-region replication (if needed)
  - [ ] Disaster recovery plan documented

## 📞 Security Contacts

- **Security Issues**: security@infrakraft.com
- **General Support**: support@infrakraft.com
- **Emergency**: Include "[URGENT]" in subject line

## 📚 Additional Resources

- [AWS Connect Security Best Practices](https://docs.aws.amazon.com/connect/latest/adminguide/security.html)
- [AWS Security Hub](https://aws.amazon.com/security-hub/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

**Last Updated**: 2024-04-17