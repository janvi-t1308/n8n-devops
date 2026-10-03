provider "aws" {

  region = var.aws_region

  default_tags {

    tags = {
      Project    = "n8n"
      Managed_By = "Terraform"
    }
  }
}