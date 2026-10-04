variable "aws_region" {

  description = "AWS Region where the resource will be created."
  type        = string

}

variable "instance_type" {

  description = "EC2 instance type for the n8n server"
  type        = string
}

#this variable should be used only when running terraform from local because while running from github actions the local ssh public key
#can't be find as the workflow runs on the runner which doesn't have the local public key  
# variable "public_key_path" {
#   description = "Path to the SSH public key"
#   type        = string
# }

variable "SSH_public_key" {
  description = "SSH Public key used for EC2"
  type = string
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