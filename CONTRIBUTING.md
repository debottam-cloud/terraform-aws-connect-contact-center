# Contributing to AWS Connect Contact Center Module

First off, thank you for considering contributing! This project is in active development and we welcome contributions of all kinds.

## 🎯 Project Status

This project is currently in **pre-release development** (v0.1.0-alpha). We're building incrementally with a focus on quality and stability.

## 🤝 How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check the [issue tracker](https://github.com/infrakraft/terraform-aws-connect-contact-center/issues) to see if it's already reported
- Collect information about the bug:
  - Terraform version (`terraform version`)
  - AWS provider version
  - Module version
  - Relevant configuration
  - Error messages

**Submit a bug report:**
1. Use the bug report template
2. Provide a clear, descriptive title
3. Include steps to reproduce
4. Include expected vs actual behavior
5. Add any relevant logs or screenshots

### Suggesting Enhancements

We welcome feature suggestions! Please:
1. Check if it's already suggested
2. Use the feature request template
3. Explain the use case
4. Describe the desired behavior
5. Consider the impact on existing features

### Code Contributions

#### Development Setup

````bash
# Clone the repository
git clone https://github.com/infrakraft/terraform-aws-connect-contact-center.git
cd terraform-aws-connect-contact-center

# Install dependencies
pip3 install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Install TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Initialize TFLint
tflint --init
````

#### Development Workflow

1. **Fork the repository**

2. **Create a feature branch**
````bash
   git checkout -b feature/amazing-feature
   # or
   git checkout -b fix/bug-description
````

3. **Make your changes**
   - Follow the code style guidelines
   - Add tests for new functionality
   - Update documentation

4. **Run validation**
````bash
   # Format code
   terraform fmt -recursive
   
   # Validate Terraform
   terraform validate
   
   # Run TFLint
   tflint --recursive
   
   # Run tests (when available)
   make test
````

5. **Commit your changes**
````bash
   git add .
   git commit -m "feat: add amazing feature"
````
   
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `style:` - Code style changes (formatting)
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

6. **Push to your fork**
````bash
   git push origin feature/amazing-feature
````

7. **Open a Pull Request**
   - Use the PR template
   - Link related issues
   - Describe what changed and why
   - Include testing details

## 📋 Code Style Guidelines

### Terraform Code Style

````hcl
# Good: Clear variable names
variable "instance_alias" {
  description = "The alias for the Connect instance"
  type        = string
}

# Bad: Unclear variable names
variable "alias" {
  type = string
}

# Good: Comprehensive descriptions
variable "contact_lens_enabled" {
  description = <<-EOT
    Whether to enable Contact Lens for Amazon Connect.
    Provides real-time and post-call analytics.
    Note: Additional charges apply ($0.015/min analyzed)
  EOT
  type        = bool
  default     = false
}

# Good: Input validation
variable "instance_alias" {
  type = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,60}[a-z0-9]$", var.instance_alias))
    error_message = "instance_alias must meet AWS naming requirements"
  }
}

# Good: Organized structure
# ============================================================================
# Section Header
# ============================================================================

resource "aws_connect_instance" "this" {
  # Required attributes
  instance_alias           = var.instance_alias
  identity_management_type = var.identity_management_type
  
  # Optional attributes
  inbound_calls_enabled  = var.inbound_calls_enabled
  outbound_calls_enabled = var.outbound_calls_enabled
  
  # Tags
  tags = var.tags
}
````

### File Organization

module/
├── main.tf           # Main resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider requirements
├── iam.tf            # IAM resources (if significant)
├── data.tf           # Data sources (if needed)
└── README.md         # Module documentation

### Documentation Standards

````hcl
# Variable documentation
variable "example" {
  description = <<-EOT
    Brief one-line description.
    
    Detailed explanation of what this variable does.
    Include constraints, examples, and use cases.
    
    Default: <default_value>
    Example: "example-value"
  EOT
  type    = string
  default = "default-value"
}

# Output documentation
output "example_id" {
  description = "The ID of the example resource"
  value       = aws_example.this.id
}
````

### README Template for Modules

````markdown
# Module Name

Brief description of what this module does.

## Features

- Feature 1
- Feature 2

## Usage

```hcl
module "example" {
  source = "./modules/example"
  
  # Configuration
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

## Outputs

| Name | Description |
|------|-------------|

## Examples

See [examples/](../../examples/) for complete examples.
````

## 🧪 Testing Guidelines

### Manual Testing

````bash
# Navigate to example
cd examples/minimal

# Initialize
terraform init

# Plan
terraform plan

# Apply to test account
terraform apply

# Verify functionality
# ... test the deployed resources ...

# Clean up
terraform destroy
````

### Automated Testing (Coming Soon)

We'll be implementing Terratest for automated testing. Examples:

````go
// Test instance creation
func TestConnectInstance(t *testing.T) {
    // Test code
}
````

## 📚 Documentation Contributions

Documentation is crucial! You can help by:

- Fixing typos or unclear explanations
- Adding examples
- Improving diagrams
- Writing tutorials
- Translating documentation

### Documentation Style

- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Link to AWS documentation
- Keep it up-to-date

## 🔍 Code Review Process

All contributions go through code review:

1. **Automated Checks**
   - GitHub Actions run automatically
   - Must pass: formatting, validation, linting

2. **Manual Review**
   - Maintainers review code
   - Check for best practices
   - Verify documentation
   - Test functionality

3. **Feedback**
   - Reviewers provide constructive feedback
   - Address comments
   - Update PR as needed

4. **Approval & Merge**
   - Requires approval from maintainer
   - Squash and merge to main

## 🎯 Focus Areas for v0.1.0

We're currently focusing on:

- ✅ Connect instance creation
- ✅ Storage configuration
- ✅ IAM roles and permissions
- ✅ Documentation
- ✅ Examples

Future focus areas will be communicated in the roadmap.

## 💬 Communication

- **Issues** - Bug reports and feature requests
- **Discussions** - Questions and general discussion
- **Pull Requests** - Code contributions
- **Email** - support@infrakraft.com for private matters

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

### Our Standards

**Positive behavior:**
- Using welcoming language
- Being respectful of differing viewpoints
- Accepting constructive criticism
- Focusing on what's best for the community
- Showing empathy

**Unacceptable behavior:**
- Harassment or discriminatory language
- Trolling or insulting comments
- Public or private harassment
- Publishing private information
- Unprofessional conduct

### Enforcement

Instances of unacceptable behavior may be reported to support@infrakraft.com. All complaints will be reviewed and investigated.

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes (for significant contributions)
- README acknowledgments

## ❓ Questions?

Don't hesitate to ask questions:
- Open a [Discussion](https://github.com/infrakraft/terraform-aws-connect-contact-center/discussions)
- Email support@infrakraft.com
- Check existing issues and PRs

---

Thank you for contributing! 🎉