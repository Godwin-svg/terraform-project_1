# create vpc 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project-name}-vpc"
  }
}

# create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id 

    tags = {
    Name = "${var.project-name}-igw"
  }
  
}

# public subnet 1a
resource "aws_subnet" "public_subnet_1a" {
    cidr_block = var.public_subnet_1a_cidr 
    vpc_id = aws_vpc.vpc.id 
    map_public_ip_on_launch =  true 
    availability_zone = "us-east-1a"

    tags = {
    Name = "${var.project-name}-public_subnet_1a"
  }
  
}


# public subnet 1b
resource "aws_subnet" "public_subnet_1b" {
    cidr_block = var.public_subnet_1b_cidr 
    vpc_id = aws_vpc.vpc.id 
    map_public_ip_on_launch =  true 
    availability_zone = "us-east-1b"

    tags = {
    Name = "${var.project-name}-public_subnet_1b"
  }
  
}

# public subnet 1c
resource "aws_subnet" "public_subnet_1c" {
    cidr_block = var.public_subnet_1c_cidr 
    vpc_id = aws_vpc.vpc.id 
    map_public_ip_on_launch =  true 
    availability_zone = "us-east-1c"

    tags = {
    Name = "${var.project-name}-public_subnet_1c"
  }
  
}

# create route table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.vpc.id 

    route {
        cidr_block = var.default_cidr
        gateway_id = aws_internet_gateway.igw.id 
    }

    tags = {
    Name = "${var.project-name}-public_rt"
  }
  
}

# public subnet 1a route table association
resource "aws_route_table_association" "public_subnet_1a_rt_association" {
    route_table_id = aws_route_table.public_rt.id 
    subnet_id = aws_subnet.public_subnet_1a.id   
}

# public subnet 1b route table association
resource "aws_route_table_association" "public_subnet_1b_rt_association" {
    route_table_id = aws_route_table.public_rt.id 
    subnet_id = aws_subnet.public_subnet_1b.id   
}

# public subnet 1c route table association
resource "aws_route_table_association" "public_subnet_1c_rt_association" {
    route_table_id = aws_route_table.public_rt.id 
    subnet_id = aws_subnet.public_subnet_1c.id    
}

# create private suubnets
# private subnet 1a
resource "aws_subnet" "private_subnet_1a" {
    cidr_block = var.private_subnet_1a_cidr 
    vpc_id = aws_vpc.vpc.id 
    map_public_ip_on_launch =  false
    availability_zone = "us-east-1a"

    tags = {
    Name = "${var.project-name}-private_subnet_1a"
  }
  
}

# private subnet 1b
resource "aws_subnet" "private_subnet_1b" {
    cidr_block = var.private_subnet_1b_cidr  
    vpc_id = aws_vpc.vpc.id 
    map_public_ip_on_launch =  false
    availability_zone = "us-east-1b"

    tags = {
    Name = "${var.project-name}-private_subnet_1b"
  }
  
}

# private subnet 1c
resource "aws_subnet" "private_subnet_1c" {
    cidr_block = var.private_subnet_1c_cidr   
    vpc_id = aws_vpc.vpc.id 
    map_public_ip_on_launch =  false
    availability_zone = "us-east-1c"

    tags = {
    Name = "${var.project-name}-private_subnet_1c"
  }
  
}

# create elastic ip address
resource "aws_eip" "alloction_ip" {
    domain = "vpc"

    tags = {
    Name = "${var.project-name}-alloction_ip"
  }

    depends_on = [aws_internet_gateway.igw]

  
}

# create nat gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.alloction_ip.id 
    subnet_id = aws_subnet.public_subnet_1a.id 

    tags = {
    Name = "${var.project-name}-nat_gateway"
  }

    depends_on = [aws_internet_gateway.igw]
}

# create private route table for az1a
resource "aws_route_table" "private_rt_az1a" {
    vpc_id = aws_vpc.vpc.id 

    route {
        cidr_block = var.default_cidr
        nat_gateway_id = aws_nat_gateway.nat_gateway.id 
    }

     tags = {
    Name = "${var.project-name}-private_rt_az1a"
  }

}

# create private route table for az1b
resource "aws_route_table" "private_rt_az1b" {
    vpc_id = aws_vpc.vpc.id 

    route {
        cidr_block = var.default_cidr
        nat_gateway_id = aws_nat_gateway.nat_gateway.id 
    }

     tags = {
    Name = "${var.project-name}-private_rt_az1b"
  }

}

# create private route table for az1c
resource "aws_route_table" "private_rt_az1c" {
    vpc_id = aws_vpc.vpc.id 

    route {
        cidr_block = var.default_cidr
        nat_gateway_id = aws_nat_gateway.nat_gateway.id 
    }

     tags = {
    Name = "${var.project-name}-private_rt_az1c"
  }

}

# private subnet az1a route table association
resource "aws_route_table_association" "private_subnet_1a_association" {
    route_table_id = aws_route_table.private_rt_az1a.id 
    subnet_id = aws_subnet.private_subnet_1a.id 
}

# private subnet az1b route table association
resource "aws_route_table_association" "private_subnet_1b_association" {
    route_table_id = aws_route_table.private_rt_az1b.id  
    subnet_id = aws_subnet.private_subnet_1b.id  
}

# private subnet az1a route table association
resource "aws_route_table_association" "private_subnet_1c_association" {
    route_table_id = aws_route_table.private_rt_az1c.id  
    subnet_id = aws_subnet.private_subnet_1c.id 
}