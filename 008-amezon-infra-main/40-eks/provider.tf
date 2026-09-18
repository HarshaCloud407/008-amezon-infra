terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-kothadi-hyd"
    key            = "roboshop-dev-eks"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}