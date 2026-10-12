terraform {

  required_version = ">= 1.13, <2.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }

  backend "s3" {
    bucket       = "n8n-devops-project-backend-s3-bucket"
    key          = "terraform/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}