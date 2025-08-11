
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