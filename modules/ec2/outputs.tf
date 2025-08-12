output "instance_id" {
  description = "List of all instance ids"
  value       = [for instance in aws_instance.here : instance.id]
}

