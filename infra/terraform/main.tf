terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
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

# App Runner service
resource "aws_apprunner_service" "service" {
  service_name = "stack-simple"

  source_configuration {
    authentication_configuration {
      access_role_arn = "arn:aws:iam::977099018154:role/service-role/AppRunnerECRAccessRole"
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.repo.repository_url}:latest"
      image_repository_type = "ECR"

      image_configuration {
        port = "8000"
        runtime_environment_variables = {
          # Add any env vars your app needs
          ENV = "prod"
        }
      }
    }
  }

  instance_configuration {
    cpu    = "1024"  # 1 vCPU
    memory = "2048"  # 2 GB
  }
}

# Output the service URL
output "service_url" {
  value = aws_apprunner_service.service.service_url
}
