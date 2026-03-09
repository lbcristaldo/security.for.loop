variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID of the application"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100
}

variable "backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}
