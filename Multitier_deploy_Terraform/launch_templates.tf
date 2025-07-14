# Launch template security group
resource "aws_security_group" "launch-template-sg" {
    name = "launch template security group"
    description = "to allow traffic from application load balancer"
    vpc_id = aws_vpc.dev.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
    Name = "my-launchtemplate-sg"
  }
  
}



# Setup Launch Templates
resource "aws_launch_template" "dev-lt" {
    name = "my-launch-template"
    image_id = var.my-ami
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.launch-template-sg.id]
    user_data = filebase64("scripts/apache.sh")

    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "dev_launch_template"

      }

    }


}