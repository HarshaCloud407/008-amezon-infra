terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.73.0"
    }
  }

  backend "s3" {
    bucket = "bucket-kothadi-hyd"
    key    = "roboshop-cdn"
    region = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}