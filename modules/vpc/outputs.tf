locals {
  output_public_subnets = {
    for key in keys(local.public_subnets) : key => {
      subnet_id         = aws_subnet.here[key].id
      availability_zone = aws_subnet.here[key].availability_zone
    }
  }

  output_private_subnets = {
    for key in keys(local.private_subnets) : key => {
      subnet_id         = aws_subnet.here[key].id
      availability_zone = aws_subnet.here[key].availability_zone
    }
  }
}

output "vpc_id" {
  description = "The AWS ID from the created VPC"
  value       = aws_vpc.here.id
}

output "public_subnets" {
  description = "The ID and the availability zone of public subnets"
  value       = local.output_public_subnets
}

output "private_subnets" {
  description = "The ID and the availability zone of private subnets"
  value       = local.output_private_subnets
}

output "elastic_ip" {
  description = "The IP address of this elastic ip"
  value       = aws_eip.nat[0].public_ip
}

output "internet_gateway" {
  description = "The ID of the created internet gateway"
  value       = aws_internet_gateway.here[0].id
}

output "nat_gateway" {
  description = "the ID of the vreated NAT gateway"
  value       = aws_nat_gateway.here[0].id
}
