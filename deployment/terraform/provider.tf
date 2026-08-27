terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "springboot-terraform-ec2-bucket"
    key    = "springdemo/ec2/terraform.tfstate"
    region = "ap-south-1"
  }

}

provider "aws" {
  region = "ap-south-1"
}
