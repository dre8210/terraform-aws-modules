variable "vpc_config" {
  description = "VPC configuration options. cidr_block and name are required"

  type = object({
    cidr_block = string
    name       = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The cidr_block config option must contain a valid CIDR block"

  }
}

variable "subnet_config" {
  description = <<EOT
  Accepts a map of subnet configurations. Each subnet configuration requires a cidr_block, an az and an indication of public or private subnet(default= false).
  EOT

  type = map(object({
    cidr_block = string
    public     = optional(bool, false)
    az         = string
  }))

  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The cidr_block config must have a valid CIDR block"
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}
  
