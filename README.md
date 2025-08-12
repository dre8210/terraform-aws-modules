# Terraform AWS Modules

A collection of reusable Terraform modules for AWS infrastructure provisioning with built-in security validations.

## Modules

### VPC Module (`modules/vpc/`)
Creates a complete VPC infrastructure with:
- VPC with configurable CIDR blocks
- Public and private subnets across multiple AZs
- Internet Gateway for public subnet connectivity
- NAT Gateway for private subnet outbound access
- Route tables and associations
- Availability zone validation

### Security Group Module (`modules/security-group/`)
Manages AWS Security Groups with:
- Public and private security groups
- Configurable ingress/egress rules
- CIDR block validation
- Optional allow-all egress for public security groups

### EC2 Module (`modules/ec2/`)
Provisions EC2 instances with:
- AMI validation and existence checks
- Configurable instance types and networking
- Root block device configuration
- Detailed monitoring options
- Comprehensive tagging strategy

## Security Features

### Port Security Validation
Includes a `null_resource` that validates sensitive ports are not exposed to the internet:
- Checks if sensitive ports (SSH, RDP, databases) are open to `0.0.0.0/0`
- Fails deployment if dangerous configurations are detected
- Prevents accidental exposure of critical services

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"
  # VPC configuration
}

module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
  # Security group rules
}

module "ec2" {
  source = "./modules/ec2"
  # EC2 instance configuration
}
```

## License

Licensed under the terms specified in the LICENSE file.