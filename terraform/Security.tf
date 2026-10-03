resource "aws_security_group" "n8n_sg" {
  name        = "n8n_security_group"
  description = "Security groups for n8n"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "n8n-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.n8n_sg.id
  description       = "Allow SSH access"

  ip_protocol = "tcp"

  from_port = 22
  to_port   = 22

  cidr_ipv4 = "157.48.195.194/32"
}

resource "aws_vpc_security_group_ingress_rule" "n8n" {
  security_group_id = aws_security_group.n8n_sg.id
  description       = "Allow n8n access"

  ip_protocol = "tcp"

  from_port = 5678
  to_port   = 5678

  # Only the ALB is allowed to forward requests to n8n.
  referenced_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.n8n_sg.id
  description       = "Allow all outbound traffic"

  ip_protocol = -1

  cidr_ipv4 = "0.0.0.0/0"

}