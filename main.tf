# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# 1. create vpc
# Create a VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2. create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}


# 3. create custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # default
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "production"
  }
}


# 4. create a subnet
resource "aws_subnet" "my-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b" # 可用區域
  tags = {
    Name = "production"
  }
}

# 5. associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_vpc.prod-vpc.id
  route_table_id = aws_route_table.prod-route-table.id
}


# 6. create security group to allow port 22,80,443
# 7. create a network interface with an ip in the subnet that was created in step4
# 8. assign an elastic ip to the network interface created in step7
# 9. create Ubuntu server and install/enable apache2
