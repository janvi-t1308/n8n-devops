data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##########################################################
# EC2 Instance
#
# Hosts the n8n application.
# Although an ALB is used to serve client traffic, the
# instance remains in the public subnet for this learning
# project so it can be accessed via SSH.
##########################################################

resource "aws_instance" "n8n_server" {

  vpc_security_group_ids = [aws_security_group.n8n_sg.id]

  subnet_id = aws_subnet.public_A.id

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = aws_key_pair.developer.key_name

  # Execute the initialization script on the first boot.
  user_data = file("${path.module}/../bootstrap/user-data.sh")

  tags = {
    Name = "n8n-server"
  }
}