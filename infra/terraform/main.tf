terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.25.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  shared_config_files = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
}

resource "aws_ecr_repository" "repo" {
  name                 = "stack-simple"
  image_tag_mutability = "MUTABLE"  # or IMMUTABLE
}

resource "aws_iam_role" "app_runner_ecr_access" {
  name = "app-runner-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the ECR access policy to the role
resource "aws_iam_role_policy_attachment" "app_runner_ecr_policy" {
  role       = aws_iam_role.app_runner_ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "apprunner" {
  name   = "apprunner-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgres" {
  name   = "postgres-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.apprunner.id]
  }
}

# RDS Instance

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = "stack-db"

  engine               = "postgres"
  engine_version       = "16"
  family              = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t4g.micro"

  allocated_storage = 20
  storage_type     = "gp3"

  db_name  = var.postgres_db
  username = var.postgres_user
  password = var.postgres_password
  port     = var.postgres_port

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  skip_final_snapshot = true

  subnet_ids = [aws_subnet.private.id]
}

resource "aws_db_subnet_group" "postgres" {
  name       = "postgres"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_1.id]
}

# App Runner
resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "app-connector"
  subnets           = [aws_subnet.public.id]
  security_groups   = [aws_security_group.apprunner.id]
}

resource "aws_apprunner_service" "service" {
  service_name = "stack"

  source_configuration {
    auto_deployments_enabled = true
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_ecr_access.arn
    }
    image_repository {
      image_configuration {
        port = "8000"
        runtime_environment_variables = {
          DATABASE_URL = "postgres://${module.db.db_instance_username}:${var.postgres_password}@${module.db.db_instance_endpoint}/${module.db.db_instance_name}"
        }
      }
      image_identifier      = "${aws_ecr_repository.repo.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }
}

# Outputs
output "app_url" {
  value = aws_apprunner_service.service.service_url
}

output "db_endpoint" {
  value = module.db.db_instance_endpoint
}
