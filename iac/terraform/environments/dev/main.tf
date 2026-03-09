terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-app-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-dev"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "SecureApp"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev-app-vpc"
  }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                    = "dev-private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb"       = "1"
    "kubernetes.io/cluster/dev-app-cluster" = "owned"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 10}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "dev-public-subnet-${count.index}"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/dev-app-cluster" = "owned"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "rds" {
  source = "../../modules/rds"

  environment           = "dev"
  vpc_id                = aws_vpc.main.id
  subnet_ids            = aws_subnet.private[*].id
  app_security_group_id = module.eks.cluster_security_group_id
  instance_class        = "db.t3.small"
  allocated_storage     = 20
  backup_retention      = 7
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = "dev"
}

module "s3" {
  source      = "../../modules/s3"
  environment = "dev"
}

module "eks" {
  source = "../../modules/eks"

  environment         = "dev"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
  instance_types      = ["t3.medium"]
  desired_size        = 2
  max_size            = 5
  min_size            = 1
  allowed_cidr_blocks = ["0.0.0.0/0"]
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "dynamodb_tables" {
  value = {
    sessions = module.dynamodb.sessions_table_name
    events   = module.dynamodb.events_table_name
  }
}

output "s3_bucket" {
  value = module.s3.bucket_name
}

output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}
