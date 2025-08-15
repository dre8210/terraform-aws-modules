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
    type                     = string
    cidr_blocks              = optional(list(string), [])
    source_security_group_id = optional(string, "")
    from_port                = number
    to_port                  = number
    protocol                 = string
    description              = string
  }))

}

variable "security_group_config_private" {

  description = "Setup custom private security group rules"

  type = map(object({
    type                     = string
    cidr_blocks              = optional(list(string), null)
    from_port                = number
    to_port                  = number
    protocol                 = string
    description              = string
    source_security_group_id = optional(string, "")

  }))

  default = {}
}


