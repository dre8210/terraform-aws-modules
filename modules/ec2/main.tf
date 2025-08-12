locals {
  common_tags = merge(var.default_tags, {
    ManagedBy = "Terraform"
  })
}


data "aws_ami" "validation" {
  for_each    = { for k, v in var.instance_config : k => v }
  most_recent = true
  owners      = var.owners

  filter {
    name   = "image-id"
    values = [each.value.ami_id]
  }

}

resource "aws_instance" "here" {
  for_each = var.instance_config

  ami = each.value.ami_id

  lifecycle {
    precondition {
      condition     = contains(keys(data.aws_ami.validation), each.key)
      error_message = "AMI ID '${each.value.ami_id}' does not exist in AWS or is not accessible."
    }
  }

  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  associate_public_ip_address = each.value.associate_public_ip
  key_name                    = each.value.key_name
  user_data                   = each.value.user_data
  monitoring                  = var.enable_detailed_monitoring || each.value.monitoring

  tags = merge(local.common_tags, {
    Name = "${each.key}-ec2-instance"
  })

  root_block_device {
    volume_type           = each.value.root_block_device.volume_type
    volume_size           = each.value.root_block_device.volume_size
    iops                  = each.value.root_block_device.iops
    throughput            = each.value.root_block_device.throughput
    encrypted             = each.value.root_block_device.encrypted
    delete_on_termination = each.value.root_block_device.delete_on_termination

    tags = merge(local.common_tags, {
      Name = "${each.key}-root-volume"
    })
  }
}
