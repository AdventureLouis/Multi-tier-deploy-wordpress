# Security group configuration remains the same
# Security group for EC2
resource "aws_security_group" "ec2-sg" {
    name        = "dev-ec2-sg"
    description = "allow inbound traffic and all outbound"
    vpc_id      = aws_vpc.dev.id

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "dev-ec2-sg"
    }
}

# Security group rules for EC2
resource "aws_security_group_rule" "ec2_alb_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ec2-sg.id
  description             = "Allow HTTP from ALB"
}

resource "aws_security_group_rule" "ec2_alb_ingress_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ec2-sg.id
  description             = "Allow HTTPS from ALB"
}


# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "dev-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "dev-alb-sg"
  }
}

