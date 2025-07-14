resource "aws_autoscaling_group" "dev-asg" {
    name = "auto-scaling-group"
    max_size = 5
    min_size = 2
    health_check_type = "ELB"
    vpc_zone_identifier = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id, aws_subnet.private-subnet3.id]
    termination_policies = ["OldestInstance"]
    launch_template {
        id = aws_launch_template.dev-lt.id
        version = "$Latest"
        
    }
     
    target_group_arns = [aws_alb_target_group.alb-tg.arn]
  
    
}



# Create simple scaling policy below

#create a scaleout(scale up policy)
resource "aws_autoscaling_policy" "dev_scaleup_policy" {
    name = "dev_scale_out_policy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.dev-asg.name

  
}


# create a scaleout alarm
resource "aws_cloudwatch_metric_alarm" "dev_scale_up_alarm" {
    alarm_name = "scale_out_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold = 60
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"

    dimensions = {
        autoscaling_group_name = "dev-asg"
    }
    
    alarm_description = "this alarm monitors autoscaling group CPU utilization"
    alarm_actions = [aws_autoscaling_policy.dev_scaleup_policy.arn]
  
}




# Create a scale in policy(scale down policy)
resource "aws_autoscaling_policy" "dev_scalein_policy" {
    name = "dev_scale_scalein_policy"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.dev-asg.name

  
}
  

  # create a scalein alarm
resource "aws_cloudwatch_metric_alarm" "dev_scale_down_alarm" {
    alarm_name = "scale_in_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    threshold = 10
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"

    dimensions = {
        autoscaling_group_name = "dev-asg"
    }
    
    alarm_description = "this alarm monitors autoscaling group CPU utilization"
    alarm_actions = [aws_autoscaling_policy.dev_scalein_policy.arn]
  
}

