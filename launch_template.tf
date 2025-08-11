

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

