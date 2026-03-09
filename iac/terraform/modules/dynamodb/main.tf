resource "aws_dynamodb_table" "sessions" {
  name           = "${var.environment}-app-sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"
  range_key      = "user_id"

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "expiry_time"
    type = "N"
  }

  # GSI para búsqueda por usuario
  global_secondary_index {
    name            = "user_id-index"
    hash_key        = "user_id"
    projection_type = "ALL"
  }

  # TTL para sesiones expiradas
  ttl {
    attribute_name = "expiry_time"
    enabled        = true
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = {
    Name        = "${var.environment}-app-sessions"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_dynamodb_table" "events" {
  name           = "${var.environment}-app-events"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "event_id"
  range_key      = "timestamp"

  attribute {
    name = "event_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "event_type"
    type = "S"
  }

  # GSI para filtrar por tipo de evento
  global_secondary_index {
    name            = "event_type-index"
    hash_key        = "event_type"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-app-events"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
