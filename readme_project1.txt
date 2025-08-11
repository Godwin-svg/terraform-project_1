Terraform (pt.1)
Foundational Use Case
Scenario
This is a infrastuce that is use to deploy a web application,  
the goal of the infrastute is manage cpu initization, henece 
cloudwatch alarm and auto scaling scaling group was part of the 
resourse use to provision the infrastruture.
Security group was create to allow only traffic from the application load
balancer get to the apache web server.
User data was use to lunached the script in the web sever.
The Auto scaling goup is confrigure with maximium of three and mininum
of twio instances with a two instnace as desisred.
Terraform was use as infrasture as code to provision the resourse.

Prequisties
- AWS Account
- Create project reposiroy in github
- Clone project dirctory on your local machine
- Terraform basis
- AWS CLI basis
- Configured AWS credentians on your terminal


Step 1: Setting Up the Project Directory
The following file with terraform extension (.tf) are used created in the directory.
- pprovider.tf  to specify the AWS provider
- variable for input varibales
- vpc.tf to create resources for vpc
- alb.tf to create resourse for application load balancer
- asg.tf to create resourse for auto scaling group
- launch_template.tf to create resources for ec2 instances
- install_apache.sh to install apache installation script

Step2 : creating the resource bas on specific files

- provider.tf :contains provider configuration for Terraform project.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev"

}


Varibales :contains input variable definitions for Terraform configuration.

# project name
variable "project-name" {
    type = string
  default = "apache"
}

# vpc cdir block
variable "vpc_cidr" {
    type = string
  default = "10.0.0.0/16"
}

# public subnet 1a cdir block
variable "public_subnet_1a_cidr" {
    type = string
    default = "10.0.0.0/20"
}

# public subnet 1b cdir block
variable "public_subnet_1b_cidr" {
    type = string
    default = "10.0.16.0/20" 
}

# public subnet 1 cdir block
variable "public_subnet_1c_cidr" {
    type = string
    default = "10.0.32.0/20" 
}

# create defaul cidr block
variable "default_cidr" {
    type = string
    default = "0.0.0.0/0"
  
}

# private subnet 1a cdir block
variable "private_subnet_1a_cidr" {
    type = string
    default = "10.0.128.0/20"
}

# private subnet 1b cdir block
variable "private_subnet_1b_cidr" {
    type = string
    default = "10.0.144.0/20"
}

# private subnet 1c cdir block
variable "private_subnet_1c_cidr" {
    type = string
    default = "10.0.160.0/20"
}

# image ami
variable "ami" {
    type = string
    default = "ami-0de716d6197524dd9"
  
}

- security_group.tf: contains firewall rules controlling inbound and outbound traffic.

# create security group for alb
resource "aws_security_group" "alb_sg" {
    vpc_id = aws_vpc.vpc.id 
    name = "alb_security_group"
    description = "allows http and https traffic from the internet"

    tags = {
    Name = "${var.project-name}-alb_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_http" {
    security_group_id = aws_security_group.alb_sg.id 
    cidr_ipv4 = var.default_cidr
    from_port = 80
    to_port = 80
    ip_protocol = "tcp" 
}


resource "aws_vpc_security_group_ingress_rule" "alb_ingress_https" {
    security_group_id = aws_security_group.alb_sg.id 
    cidr_ipv4 = var.default_cidr
    from_port = 443
    to_port = 443
    ip_protocol = "tcp" 
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
    security_group_id = aws_security_group.alb_sg.id 
    cidr_ipv4 = var.default_cidr
    ip_protocol = "-1" 
}


# create security group for launch template
resource "aws_security_group" "ec2_sg" {
    name = "ec2-sg"
    vpc_id = aws_vpc.vpc.id 
    description = "allows traffic from alb_sg"

    tags = {
    Name = "${var.project-name}-ec2_sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ec2_sg_http" {
    security_group_id = aws_security_group.ec2_sg.id 
    description = "allows http from alb_sg"
    referenced_security_group_id = aws_security_group.alb_sg.id 
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_sg_https" {
    security_group_id = aws_security_group.ec2_sg.id 
    description = "allows https from alb_sg"
    referenced_security_group_id = aws_security_group.alb_sg.id 
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "ec2_sg_egress" {
    security_group_id = aws_security_group.ec2_sg.id 
    cidr_ipv4 = var.default_cidr
    ip_protocol = "-1"
  
}

- alb.tf contains:


# create alb
resource "aws_lb" "alb" {
    name = "Application-load-balancer"
    load_balancer_type = "application"
    security_groups = [ aws_security_group.alb_sg.id]
    subnets = [ aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id, aws_subnet.public_subnet_1c.id]
    tags = {
    Name = "${var.project-name}-Application-load-balancer"
  }
  
}

# create target group
resource "aws_lb_target_group" "lb_target_gp" {
    name = "lb-target-gp"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc.id 

    health_check {
      path = "/"
      port = 80
    }
  
}

# create listener
resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.lb_target_gp.arn
    
    }
  
}

- launch_template.tf contains:



#  create lauch template
resource "aws_launch_template" "name" {
    name = "apache_lt"
    description = "my apache_lt"
    image_id = var.ami
    instance_type = "t3.micro"
    vpc_security_group_ids = [ aws_security_group.ec2_sg.id]
    user_data = filebase64("scripts/install_apache.sh")

    tag_specifications {
      resource_type = "instance"
      tags = {
    Name = "${var.project-name}-apache-sg"
  }
    }

  
}

- install_apache.sh contains :contains commands to install and start the Apache web server.

#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html


- asg.tf contains:`asg.tf` contains configuration for an Auto Scaling Group, 
scaling policies, and CloudWatch alarms to scale instances up or down based on CPU usage.


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

Step3: Deploying the Infrastuture to AWS: 
The deployment was carried out in phases for each created resource. 
This approach made it easier to troubleshoot any issues that arose during the process.

# formated the code
- terraform fmt

# Plan the infrastructure and preview the changes to be applied:
- terfform plan

# Apply the changes to deploy the infrastructure: 
- terraform apply

# Destroy the infrastructure when no longer needed: 
- terraform destory





































