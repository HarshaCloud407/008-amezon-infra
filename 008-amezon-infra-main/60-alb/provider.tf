terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-kothadi-hyd"
    key            = "roboshop-alb-ingress"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}