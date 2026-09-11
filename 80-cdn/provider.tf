terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.73.0"
    }
  }

  backend "s3" {
    bucket = "bucket-kothadi"
    key    = "roboshop-cdn"
    region = "us-east-1"
    dynamodb_table = "kotha-dynamo-db"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}