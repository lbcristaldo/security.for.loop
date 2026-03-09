output "sessions_table_name" {
  value = aws_dynamodb_table.sessions.name
}

output "events_table_name" {
  value = aws_dynamodb_table.events.name
}

output "sessions_table_arn" {
  value = aws_dynamodb_table.sessions.arn
}

output "events_table_arn" {
  value = aws_dynamodb_table.events.arn
}
