# ---------------------------------------------------------------------------
# Terraform itself is currently using local state during the bootstrap phase.
#
# Why?
# The purpose of this configuration is to CREATE the S3 bucket that will
# eventually become Terraform's remote state backend.
#
# The S3 backend cannot be used before the bucket exists, so bootstrap
# initially relies on Terraform's default local backend.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">=1.13.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # Store Terraform bootstrap state remotely in S3.
  backend "s3" {
    bucket       = "n8n-devops-project-backend-s3-bucket"
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "n8n-devops-project-backend-s3-bucket"
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Project     = "n8n-devops"
    Name        = "n8n-devops-project-backend-s3-bucket"
    Purpose     = "Terraform remote state"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# S3 VERSIONING
#
# Terraform state is critical infrastructure data. Versioning retains
# previous versions of the state object so that an earlier version can
# potentially be recovered if the current state is overwritten or damaged.
# ---------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_bucket" {
  bucket                  = aws_s3_bucket.terraform_state_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}