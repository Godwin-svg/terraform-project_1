# create auto sclaing group
resource "aws_autoscaling_group" "asg" {
    name = "apache-asg"
    max_size =  3
    min_size = 1
    desired_capacity = 2
    vpc_zone_identifier = [ aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id, aws_subnet.private_subnet_1c.id]
    health_check_type = "ELB"
    termination_policies = [ "OldestInstance" ]
    launch_template {
      id = aws_launch_template.name.id 
      version = "$Latest"
    }

    target_group_arns = [ aws_lb_target_group.lb_target_gp.arn ]


  
}

# create scale out policy

resource "aws_autoscaling_policy" "asg_policy_up" {
    name = "apache_policy_up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.asg.name

  
}

# create scaleup alarm
resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_up" {
    alarm_name = "apache_cpu_alarm_up"
    threshold = "60"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 2
    period = 120 
    metric_name = "CPUUtilization"
    statistic = "Average"
    namespace = "AWS/EC2"

    dimensions = {
      autoscaling_group_name = aws_autoscaling_group.asg.name
    }

    alarm_description = "This alarm monitors asg cpu unitlizzaton"
    alarm_actions = [ aws_autoscaling_policy.asg_policy_up.arn ]
  
}

# create scaledown policy
resource "aws_autoscaling_policy" "asg_policy_down" {
    name = "apache_policy_down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.asg.name

  
}


# create scaledown alarm
resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_down" {
    alarm_name = "apache_cpu_alarm_down"
    threshold = "10"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = 2
    period = 120 
    metric_name = "CPUUtilization"
    statistic = "Average"
    namespace = "AWS/EC2"

    dimensions = {
      autoscaling_group_name = aws_autoscaling_group.asg.name
    }

    alarm_description = "This alarm monitors asg cpu unitlizzaton"
    alarm_actions = [ aws_autoscaling_policy.asg_policy_down.arn ]
  
}