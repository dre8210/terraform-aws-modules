output "vpc_id" {
  description = "The AWS ID from the created VPC"
  value       = aws_vpc.here.id
}

output "public_subnets_ids" {
  description = "List of all private subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnets_ids" {
  description = "List of all private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
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
  description = "the ID of the created NAT gateway"
  value       = aws_nat_gateway.here[0].id
}
