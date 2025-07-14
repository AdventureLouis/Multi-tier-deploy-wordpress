
#Create Security group for load balancer for both ingress and egress rules

resource "aws_security_group" "alb-SG" {
    name = "dev-Alb-SG"
    description = "Allow inbound traffic and all outbound"
    vpc_id = aws_vpc.dev.id


    ingress{
       from_port = 80
       to_port = 80
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]

    }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}


# Create Application Load balancer
resource "aws_alb" "alb" {
    name = "dev-alb"
    security_groups = [aws_security_group.alb-SG.id]
    subnets = [aws_subnet.public-subnet1.id,aws_subnet.public-subnet2.id,aws_subnet.public-subnet3.id]
}


# Create listerners that will direct requests to the registered targets
resource "aws_lb_listener" "alb-listener" {
    port = 80
    protocol = "HTTP"
    load_balancer_arn = aws_alb.alb.arn

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.alb-TG.arn
    }

}

# Create Application load balancer target group
resource "aws_lb_target_group" "alb-TG" {
    name = "dev-alb-TG"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.dev.id

    health_check {
        path = "/"
        port = 80
      
    }
}



