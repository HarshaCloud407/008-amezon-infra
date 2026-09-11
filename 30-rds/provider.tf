terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }

  backend "s3" {
    bucket = "bucket-kothadi-hyd"
    key    = "roboshop-dev-rds"
    region = "us-east-1"
    dynamodb_table = "kotha-dynamo-db-hyd"
  }
}

provider "aws" {
  region = "us-east-1"
}