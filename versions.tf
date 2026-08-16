terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-12-5"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile = "terraform-locks"
    encrypt        = true
  }
}