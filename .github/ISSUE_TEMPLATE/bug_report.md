---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

A clear and concise description of what the bug is.

## Steps to Reproduce

1. Configure module with '...'
2. Run 'terraform apply'
3. See error

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Configuration

```hcl
# Your Terraform configuration (sanitize sensitive data)
module "contact_center" {
  source = "infrakraft/connect-contact-center/aws"
  version = "x.x.x"
  
  # Your config here
}
```

## Environment

- **Module Version:** [e.g., 0.1.0]
- **Terraform Version:** [e.g., 1.5.7]
- **AWS Provider Version:** [e.g., 5.0.0]
- **AWS Region:** [e.g., us-east-1]
- **Operating System:** [e.g., macOS 14.0, Ubuntu 22.04]

## Error Messages

Paste any error messages or logs here

## Additional Context

Add any other context about the problem here. Screenshots can be helpful.