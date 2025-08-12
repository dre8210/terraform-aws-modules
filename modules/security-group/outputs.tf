output "public_security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.public.id
}

output "private_security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.private.id
}

output "security_group_arn" {
  description = "ARN of the created security group"
  value       = aws_security_group.public.arn
}

output "private_security_group_arn" {
  description = "ARN of the created security group"
  value       = aws_security_group.private.arn
}
