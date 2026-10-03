variable "aws_region" {

  description = "AWS Region where the resource will be created."
  type        = string

}

variable "instance_type" {

  description = "EC2 instance type for the n8n server"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the project vpc"
  type        = string
  default     = "10.0.0.0/16"
}

##########################################################
# Subnet Configuration
##########################################################

variable "public_subnet_a_cidr_range" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_b_cidr_range" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "private_subnet_a_cidr_range" {
  description = "CIDR block for private subnet A"
  type        = string
}

variable "private_subnet_b_cidr_range" {
  description = "CIDR block for private subnet B"
  type        = string
}