provider "aws"{
    region = "ap-northeast-2"
    access_key="###"
    secret_key="###"
    
}

resource "aws_vpc" "awsvpcec2"{
    cidr_block = "190.0.0.0/16"
    instance_tenancy = "default"

  tags = {
    Name = "awsvpcec2"
  }
}

resource "aws_subnet" "subnet-1pubec2"{
    vpc_id = aws_vpc.awsvpcec2.id
    cidr_block = "190.0.0.0/24"
    availability_zone = "ap-northeast-2a"
    tags= {
        name :"public"
    }
}


resource "aws_subnet" "subnet-1priec2"{
    vpc_id = aws_vpc.awsvpcec2.id
    cidr_block = "190.0.1.0/24"
    availability_zone = "ap-northeast-2b"
    tags= {
        name :"private"
    }
}

resource "aws_internet_gateway" "igwec2" {
  vpc_id = aws_vpc.awsvpcec2.id

  tags = {
    Name = "igateway"
  }
}

resource "aws_eip" "eipec2" {
  vpc      = true
}

resource "aws_nat_gateway" "ngwec2" {
  allocation_id = aws_eip.eipec2.id
  subnet_id     = aws_subnet.subnet-1pubec2.id

  tags = {
    Name = "NGW"
  }
}

resource "aws_route_table" "rtable1pubec2" {
  vpc_id = aws_vpc.awsvpcec2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwec2.id
  }
  tags = {
    Name = "routetable1"
  }
}

resource "aws_route_table" "rtable2priec2" {
  vpc_id = aws_vpc.awsvpcec2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngwec2.id
  }
  tags = {
    Name = "routetable2ec2"
  }
}

resource "aws_route_table_association" "association1ec2" {
  subnet_id      = aws_subnet.subnet-1pubec2.id
  route_table_id = aws_route_table.rtable1pubec2.id
}

resource "aws_route_table_association" "association2ec2" {
  subnet_id      = aws_subnet.subnet-1priec2.id
  route_table_id = aws_route_table.rtable2priec2.id
}

resource "aws_security_group" "sgec2" {
  name        = "securitygrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.awsvpcec2.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "securitygrpec2"
  }
}
