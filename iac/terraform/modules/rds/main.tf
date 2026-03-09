resource "aws_db_instance" "postgres" {
  identifier = "${var.environment}-app-db"

  engine         = "postgres"
  engine_version = "15.3"
  instance_class = var.instance_class

  db_name  = "appdb"
  username = var.db_username
  password = random_password.db_password.result

  allocated_storage     = var.allocated_storage
  storage_encrypted     = true
  storage_type         = "gp3"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.backup_retention
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-05:00"

  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment != "prod"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name        = "${var.environment}-app-db"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "random_password" "db_password" {
  length  = 32
  special = false
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}
