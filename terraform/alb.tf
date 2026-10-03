##########################################################
# Security Group for Application Load Balancer
#
# Allows HTTP and HTTPS traffic from the Internet.
##########################################################

resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.main.id
  description = "security group for application load balancer"
  name        = "${local.project_name}-alb-sg"

  tags = {
    Name = "${local.project_name}-alb-sg"
  }
}

##########################################################
# Allow HTTP
##########################################################

resource "aws_vpc_security_group_ingress_rule" "alb_http" {

  security_group_id = aws_security_group.alb_sg.id
  description       = "allow http traffic"

  # Allow traffic from any IPv4 address. when in egress rule, then it means, Allow traffic to any IPv4 address.
  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "tcp"

  from_port = 80
  to_port   = 80

}

##########################################################
# Allow HTTPS
##########################################################

resource "aws_vpc_security_group_ingress_rule" "alb-https" {

  description = "allow HTTPS traffic"

  security_group_id = aws_security_group.alb_sg.id

  ip_protocol = "tcp"

  from_port = 443
  to_port   = 443

  cidr_ipv4 = "0.0.0.0/0"
}

##########################################################
# Allow outbound traffic
##########################################################

resource "aws_vpc_security_group_egress_rule" "alb-outbound" {

  description = "Allow ALB to forward requests to the EC2 application."

  security_group_id = aws_security_group.alb_sg.id

  ip_protocol = "tcp"

  # allow the traffic, which is only intended for below port range
  from_port = 5678
  to_port   = 5678

  # Allow the ALB to forward requests only to resources associated with the n8n Security Group.
  referenced_security_group_id = aws_security_group.n8n_sg.id

}


##########################################################
# Application Load Balancer
#
# Serves as the public entry point for the application.
# Receives client requests and forwards them to the
# registered backend targets.
##########################################################

resource "aws_lb" "n8n_alb" {

  name = "${local.project_name}-n8n-alb"

  # Makes the ALB accessible from the Internet.
  # Set to true for an internal ALB that is only
  # reachable from within the VPC.
  internal = false

  # Creates an Application Load Balancer (Layer 7),
  # which understands HTTP and HTTPS traffic.
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_A.id,
    aws_subnet.public_B.id
  ]

  # Prevent accidental deletion in production.
  enable_deletion_protection = false

  tags = {
    Name = "${local.project_name}-n8n-alb"
  }
}

##########################################################
# Target Group
#
# Defines the backend resources that receive traffic
# from the Application Load Balancer.
#
# It is also responsible for performing periodic health
# checks to ensure requests are sent only to healthy
# application instances.
##########################################################

resource "aws_lb_target_group" "n8n_alb_tg" {

  name = "${local.project_name}-n8n-alb-tg"

  # All registered targets must belong to this VPC.
  vpc_id = aws_vpc.main.id

  # Port on which the backend application (n8n) is listening.
  port = 5678

  # Protocol used by the ALB to communicate with the backend application.
  protocol = "HTTP"

  # Targets are EC2 instances.
  # Other supported target types include "ip" and "lambda".
  target_type = "instance"

  ########################################################
  # Health Check Configuration
  ########################################################

  health_check {

    # Perform the health check on the same port used for forwarding client requests.
    port = "traffic-port"

    # Use HTTP requests to verify the application is healthy, not just that the TCP port is open.
    protocol = "HTTP"

    # Send an HTTP GET request to the application's root endpoint.
    path = "/"

    # A 200 HTTP response indicates that the application is healthy.
    matcher = "200"
  }

  tags = {
    Name = "${local.project_name}-n8n-alb-tg"
  }

}

##########################################################
# HTTP Listener
#
# Listens for incoming HTTP requests on port 80 and
# forwards them to the n8n Target Group.
##########################################################

resource "aws_lb_listener" "n8n-alb-listener" {

  # Application Load Balancer that will receive client requests.
  load_balancer_arn = aws_lb.n8n_alb.arn

  # Port exposed to clients.
  port = 80

  # Listen for HTTP requests.
  protocol = "HTTP"

  default_action {

    # Forward all incoming requests to the Target Group.
    type = "forward"

    target_group_arn = aws_lb_target_group.n8n_alb_tg.arn
  }

  tags = {
    Name = "${local.project_name}-n8n-alb-listener"
  }
}

##########################################################
# Target Group Attachment
#
# Registers the EC2 instance with the Target Group so
# that the ALB can forward requests to it.
##########################################################

resource "aws_lb_target_group_attachment" "n8n" {

  # Target Group that will receive the registered instance.
  target_group_arn = aws_lb_target_group.n8n_alb_tg.arn

  # EC2 instance to register with the Target Group.
  target_id = aws_instance.n8n_server.id

  # Port on which the application is listening.
  # This should match the Target Group's traffic port.
  port = 5678
}