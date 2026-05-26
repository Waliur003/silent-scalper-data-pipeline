//Configure Terraform provider with version more or same as 5.0.0
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

//Configure AWS provider with region 
provider "aws" {
    region = var.aws_region
    }