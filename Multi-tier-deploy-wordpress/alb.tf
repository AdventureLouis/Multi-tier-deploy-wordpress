
# Create Target Group
resource "aws_lb_target_group" "wordpress_tg" {
  name     = "dev-wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval           = 30
    matcher            = "200,301,302"
    path              = "/wp-admin/install.php"
    port              = "traffic-port"
    protocol          = "HTTP"
    timeout           = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "dev-wordpress-tg"
  }
}

# Create Application Load Balancer
resource "aws_lb" "wordpress_alb" {
  name               = "dev-wordpress-alb"
  internal          = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [
    aws_subnet.public-subnet1-eu-west-1a.id,
    aws_subnet.public-subnet2-eu-west-1b.id  # Make sure you have this subnet defined
  ]

  enable_deletion_protection = false

  tags = {
    Name = "dev-wordpress-alb"
  }
}


# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "wordpress_tg_attachment" {
  target_group_arn = aws_lb_target_group.wordpress_tg.arn
  target_id        = aws_instance.dev-ec2.id
  port            = 80
}

