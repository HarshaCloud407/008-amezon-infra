# provider.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.29.0"
    }
  }

  backend "s3" {
    bucket       = "bucket-kothadi-hyd2"   # keep your existing bucket name
    key          = "dev/security-group/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "roboshop"
      Environment = "dev"
      Terraform   = "true"
    }
  }
}