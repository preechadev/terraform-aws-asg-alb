
// additional codes for Application LB
# Application Load Balancer Resources
## Security Group Resources

resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "ingress IGW"
  }
}

resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-alb-security-group"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-security-group"
  }
}


resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
#  subnets            = [for i in aws_subnet.public_subnet : i.id]
  subnets = ["subnet-0a8b3109ab2a4cfe3", "subnet-0b742e9580b3026d9"]
  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.environment}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}Enter file contents here
