terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket = "bucket-kothadi-hyd"
    key    = "roboshop-vpc"
    region = "us-east-1"
    dynamodb_table = "kotha-dynamo-db-hyd"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}