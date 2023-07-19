# Terraform Settings Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.6.2"
    }
  }
}

# Provider Block
provider "aws" {
  region = "eu-north-1"
}


