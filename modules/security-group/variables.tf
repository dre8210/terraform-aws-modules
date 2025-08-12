variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "name_prefix" {
  description = "VPC ID for the security group"
  type        = string
  default     = "main-sg-"
}

variable "allow_all_egress" {
  type    = bool
  default = false

}

variable "security_group_config" {

  description = "Setup custom security group rules"

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
      for rule in values(var.security_group_config) :
      alltrue([for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))])
    ])
    error_message = "All CIDRs must be valid."
  }
}
