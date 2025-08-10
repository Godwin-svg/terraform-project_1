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

