resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.environment}-app-storage-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${var.environment}-app-storage"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = var.environment == "prod" ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    id     = "expire-old-files"
    status = "Enabled"

    expiration {
      days = 365
    }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 270
      storage_class = "GLACIER"
    }
  }
}

data "aws_caller_identity" "current" {}
