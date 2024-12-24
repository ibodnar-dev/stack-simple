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
