terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.37.0"
    }
  }

  backend "s3" {
    bucket = "bucket-kothadi-hyd"
    key    = "roboshop-tools"
    region = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}