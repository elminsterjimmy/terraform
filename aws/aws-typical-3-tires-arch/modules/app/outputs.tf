output "app_security_group_id" {
  description = "The ID of the application tier's security group"
  value       = aws_security_group.app_sg.id
}