output "endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "port" {
  value = aws_db_instance.postgres.port
}

output "database_name" {
  value = aws_db_instance.postgres.db_name
}

output "username" {
  value = aws_db_instance.postgres.username
}

output "password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
