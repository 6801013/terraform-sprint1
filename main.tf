provider "aws" {
  region = "ap-northeast-1"
}

# 変数定義
variable "web_name" {
  type    = string
  default = "web"
}

variable "api_name" {
  type    = string
  default = "api"
}

# --------------------------
# VPC（共通）
# --------------------------
resource "aws_vpc" "web_vpc" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name = "reservation-vpc"
  }
}

# --------------------------
# Internet Gateway（共通）
# --------------------------
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "${var.web_name}-igw-01"
  }
}

# --------------------------
# Webサブネット & ルート
# --------------------------
resource "aws_subnet" "web_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.0.0/24"

  tags = {
    Name = "${var.web_name}-subnet-01"
  }
}

resource "aws_route_table" "web_public_rtb" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }

  tags = {
    Name = "${var.web_name}-routetable"
  }
}

resource "aws_route_table_association" "web_public_rtb_assoc" {
  subnet_id      = aws_subnet.web_subnet.id
  route_table_id = aws_route_table.web_public_rtb.id
}

# --------------------------
# APIサブネット & ルート
# --------------------------
resource "aws_subnet" "api_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "${var.api_name}-subnet-01"
  }
}

resource "aws_route_table" "api_public_rtb" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }

  tags = {
    Name = "${var.api_name}-routetable"
  }
}

resource "aws_route_table_association" "api_public_rtb_assoc" {
  subnet_id      = aws_subnet.api_subnet.id
  route_table_id = aws_route_table.api_public_rtb.id
}

# --------------------------
# Webセキュリティグループ
# --------------------------
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.web_vpc.id

  name        = "${var.web_name}-sg"
  description = "Allow HTTP and SSH access"

  ingress {
    description = "Allow HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.web_name}-sg-01"
  }
}

# --------------------------
# APIセキュリティグループ
# --------------------------
resource "aws_security_group" "api_sg" {
  vpc_id = aws_vpc.web_vpc.id

  name        = "${var.api_name}-sg"
  description = "Allow HTTP and SSH access"

  ingress {
    description = "Allow HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.api_name}-sg-01"
  }
}

# --------------------------
# Web EC2
# --------------------------
resource "aws_instance" "web_ec2" {
  ami           = "ami-0bc8f29a8fc3184aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet.id
  security_groups = [aws_security_group.web_sg.id]
  key_name      = "test-ec2-key"
  tags = {
    Name = "${var.web_name}-server"
  }
}

# --------------------------
# API EC2
# --------------------------
resource "aws_instance" "api_ec2" {
  ami           = "ami-0bc8f29a8fc3184aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.api_subnet.id
  security_groups = [aws_security_group.api_sg.id]
  key_name      = "test-ec2-key"

  tags = {
    Name = "${var.api_name}-server"
  }
}
