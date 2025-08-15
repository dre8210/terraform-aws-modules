variable "instance_config" {
  description = "EC2 Instance Configuration"

  type = map(object({
    ami_id                  = string
    instance_type           = string
    vpc_security_group_ids  = list(string)
    subnet_id               = string
    key_name                = optional(string)
    user_data               = optional
    monitoring              = optional(bool, false)
    ebs_optimized           = optional(bool, false)
    disable_api_termination = optional(bool, false)
    associate_public_ip     = optional(bool, false)

    root_block_device = optional(object({
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 20)
      iops                  = optional(number)
      throughput            = optional(number)
      encrypted             = optional(bool, true)
      delete_on_termination = optional(bool, true)
    }), {})

  }))

  validation {
    condition = alltrue([
      for ami in values(var.instance_config) :
      can(regex("^ami-[0-9A-Fa-f]{8,17}$", ami.ami_id))
    ])
    error_message = "Each AMI ID must match the AWS format: ami-xxxxxxxx or ami-xxxxxxxxxxxxxxxxx."
  }
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "owners" {
  description = "List of AMI owners to allow (e.g., self, amazon)"
  type        = list(string)
}
