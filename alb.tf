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