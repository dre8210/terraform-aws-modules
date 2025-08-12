variable "vpc_config" {
  description = "VPC configuration options. cidr_block and name are required"

  type = object({
    cidr_block           = string
    name                 = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The cidr_block config option must contain a valid CIDR block"

  }
}

variable "public_subnet_config" {
  description = <<EOT
  Accepts a map of subnet configurations. Each subnet configuration requires a cidr_block, an az and an indication of public or private subnet(default= false).
  EOT

  type = map(object({
    cidr_block = string
    az         = string
  }))

  validation {
    condition = alltrue([
      for config in values(var.public_subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The cidr_block config must have a valid CIDR block"
  }
}

variable "private_subnet_config" {
  description = <<EOT
  Accepts a map of subnet configurations. Each subnet configuration requires a cidr_block, an az and an indication of public or private subnet(default= false).
  EOT

  type = map(object({
    cidr_block = string
    az         = string
  }))

  validation {
    condition = alltrue([
      for config in values(var.private_subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The cidr_block config must have a valid CIDR block"
  }

}
