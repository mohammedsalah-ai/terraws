terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  profile                  = "terraws"
  shared_credentials_files = ["~/.aws/credentials"]
}

module "development-env" {
  source = "./module"
}