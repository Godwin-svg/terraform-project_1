# project name
variable "project-name" {
    type = string
  default = "Terraform-project"
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