variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "public_name_prefix" {
  description = "VPC ID for the public security group"
  type        = string
  default     = "public-sg-"
}

variable "private_name_prefix" {
  description = "VPC ID for the private security group"
  type        = string
  default     = "private-sg-"
}

variable "public_allow_all_egress" {
  type    = bool
  default = false

}

variable "security_group_config_public" {

  description = "Setup custom public security group rules"

  type = map(object({
    type        = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))

  validation {
    condition = alltrue([
      for rule in values(var.security_group_config_public) :
      alltrue([for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))])
    ])
    error_message = "All CIDRs must be valid."
  }
}

variable "security_group_config_private" {

  description = "Setup custom private security group rules"

  type = map(object({
    type        = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))

  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.security_group_config_private) :
      alltrue([for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))])
    ])
    error_message = "All CIDRs must be valid."
  }
}

