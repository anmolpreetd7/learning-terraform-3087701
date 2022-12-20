data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

##Commenting below code. The new VPC is deployed using module now
##data "aws_vpc" "default" {
##  default = true
##}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  ##public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = ["10.0.101.0/24"]
  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.web_sg.security_group_id]

  tags = {
    Name = "HelloWorld"
  }
}

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"
  name = "web_nsg"

  vpc_id = module.vpc.public_subnets

  ingress_rules = ["http-80-tcp","https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

##Commenting below code since the new security group was created using module

##resource "aws_security_group" "web" {
##  name = "web_nsg"
##  description = "Allow http and https in. Allow everything out"

##  vpc_id = data.aws_vpc.default.id
##}

##resource "aws_security_group_rule" "web_nsg_http_in" {
##  type = "ingress"
##  from_port = 80
##  to_port = 80
##  protocol = "tcp"
##  cidr_blocks = ["0.0.0.0/0"] 

##  security_group_id = aws_security_group.web.id
##}

##resource "aws_security_group_rule" "web_nsg_https_in" {
##  type = "ingress"
##  from_port = 443
##  to_port = 443
##  protocol = "tcp"
##  cidr_blocks = ["0.0.0.0/0"] 

##  security_group_id = aws_security_group.web.id
#}

##resource "aws_security_group_rule" "web_nsg_everything_out" {
##  type = "egress"
##  from_port = 0
##  to_port = 0
##  protocol = "-1"
##  cidr_blocks = ["0.0.0.0/0"] 

##  security_group_id = aws_security_group.web.id
##}