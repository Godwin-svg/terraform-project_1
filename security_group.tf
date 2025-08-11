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