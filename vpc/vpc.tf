provider "aws" {
  access_key = "*************************"
  secret_key = "*******************************************"
  region     = "us-west-2"
}

resource "aws_vpc" "vpc_tuto" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "TestVPC"
  }
}
resource "aws_subnet" "public_subnet_us_west_2a" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
  tags = {
  	Name =  "Public-Subnet az 2a"
  }
}
resource "aws_subnet" "private_1_subnet_us_west_2a" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  tags = {
  	Name =  "Private-Subnet private 1 az 2a"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_tuto.id}"
  tags {
        Name = "InternetGateway"
    }
}
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_tuto.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}
resource "aws_eip" "tuto_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.tuto_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_us_west_2a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_tuto.id}"
 
    tags {
        Name = "Private route table"
    }
}
 
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}
resource "aws_route_table_association" "public_subnet_us_west_2a_association" {
    subnet_id = "${aws_subnet.public_subnet_us_west_2a.id}"
    route_table_id = "${aws_vpc.vpc_tuto.main_route_table_id}"
}
 
# Associate subnet private_1_subnet_us_west_2a to private route table
resource "aws_route_table_association" "pr_1_subnet_us_west_2a_association" {
    subnet_id = "${aws_subnet.private_1_subnet_us_west_2a.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}
