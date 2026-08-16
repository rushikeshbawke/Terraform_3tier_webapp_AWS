provider "aws" {
    region = var.aws_region
    shared_credentials_files = ["C:/Users/RUSHIKESH BAWKE/.aws/credentials"]
    tags = {
        ManagedBy = "Terraform"
  }
}