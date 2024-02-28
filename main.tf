
# creating vpc in aws
resource "aws_vpc" "myvpc" {
  cidr_block = "12.0.0.0/16"

  tags = {
    Name = "Terraform-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Terraform-internet-gateway"
  }
}

# resource "aws_internet_gateway_attachment" "internet-gateway-attachment" {
#   internet_gateway_id = aws_internet_gateway.gw.id
#   vpc_id              = aws_vpc.myvpc.id
# }

# public subnet in availability zone ap-south-1a
resource "aws_subnet" "public-subnet-1a" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
  }
}

# private subnet in availability zone ap-south-1a
resource "aws_subnet" "private-subnet-1a" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "12.0.2.0/24"

  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet-1a"
  }
}

# public route table
resource "aws_route_table" "public-1a-route-table" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.gw.id
    }

    tags = {
      Name = "public-1b-route-table"
    }
}

# private route table
resource "aws_route_table" "private-1a-route-table" {
    vpc_id = aws_vpc.myvpc.id


    tags = {
      Name = "private-1a-route-table"
    }
}

# associcating the public  route table to public subnets

resource "aws_route_table_association" "public-1a-route-table_association" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.public-1a-route-table.id
}

# associcating the private  route table to private subnets
resource "aws_route_table_association" "private-1a-route-table_association" {
  subnet_id      = aws_subnet.private-subnet-1a.id
  route_table_id = aws_route_table.private-1a-route-table.id
}
  

# Createing ec2 instance in public subnet

resource "aws_instance" "ssh-ec2" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = "AWS_LOGIN"
  subnet_id = aws_subnet.public-subnet-1a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "terraform-instance"  
  }

}

# creating security group for ec2 instance

resource "aws_security_group" "sg" {
    egress = [
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "AWS Security Group"
            from_port = 0
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "-1"
            security_groups = []
            self = false
            to_port = 0
        }
    ]

    ingress = [
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "AWS Security Group"
            from_port = 22
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "tcp"
            security_groups = []
            self = false
            to_port = 22
        }
    ]
  
}