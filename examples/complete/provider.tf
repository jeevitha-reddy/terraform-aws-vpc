terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0" # AWS provider version, not terraform version
    }
  }

  backend "s3" {
    bucket = "devrobo"
    key = "vpc-test"  # your wish
    region = "us-east-1"
    dynamodb_table = "devrobo-locking"
  } 
}



provider "aws" {
  region = "us-east-1"
}