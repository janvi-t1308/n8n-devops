aws_region                  = "ap-south-1"
instance_type               = "t3.small"
#this is the public key of local, for github we'll use github variables to pass the public key value
#public_key_             = "~/.ssh/id_ed25519.pub"
vpc_cidr                    = "10.0.0.0/16"
public_subnet_a_cidr_range  = "10.0.1.0/24"
public_subnet_b_cidr_range  = "10.0.2.0/24"
private_subnet_a_cidr_range = "10.0.101.0/24"
private_subnet_b_cidr_range = "10.0.102.0/24"