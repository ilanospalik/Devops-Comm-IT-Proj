# Terraform Settings Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.6.2"
    }
    }
  #   backend "s3" {
  #     bucket = "moshedabush-devops"
  #     key    = "aws-bucket-demo1.tfstate"
  #     region = "eu-west-2"
  # }
}
# Provider Block
provider "aws" {
  region = "eu-west-2"
}


