
#Create VPC
resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
     enable_dns_hostnames = true
     enable_dns_support   = true
    tags = {
      Name = "dev vpc"
    }
  
}

#Create public subnets
resource "aws_subnet" "public-subnet1-eu-west-1a" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.0.0/20"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "public_subnet1"
    }
  
}


resource "aws_subnet" "public-subnet2-eu-west-1b" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.16.0/20"
    availability_zone = "eu-west-1b"
    tags = {
        Name = "public_subnet2"
    }
  
}

resource "aws_subnet" "public-subnet3-eu-west-1c" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.32.0/20"
    tags = {
        Name = "public_subnet3"
    }
  
}

#Create private subnets
resource "aws_subnet" "private-subnet1-west-1a" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.128.0/20"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "private_subnet1"
    }
  
}

resource "aws_subnet" "private-subnet2-west-1b" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.144.0/20"
    availability_zone = "eu-west-1b"
    tags = {
        Name = "private_subnet2"
    }
  
}

resource "aws_subnet" "private-subnet3-west-1c" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.160.0/20"
    tags = {
        Name = "private_subnet3"
    }
  
}

#Create Internet gateway
resource "aws_internet_gateway" "Igw" {
    vpc_id = aws_vpc.dev.id

    tags = {
        Name = "dev Igw"
    }  
}

# Create a public route table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.dev.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Igw.id
    }
  
}

# Create route table associations for public subnets
resource "aws_route_table_association" "public_subnet1_rt" {
    subnet_id = aws_subnet.public-subnet1-eu-west-1a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2_rt" {
    subnet_id = aws_subnet.public-subnet2-eu-west-1b.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet3_rt" {
    subnet_id = aws_subnet.public-subnet3-eu-west-1c.id
    route_table_id = aws_route_table.public_rt.id
}

#Create elastic ip eip
resource "aws_eip" "elastic_ip" {
  
}
# Create Nat gateway
resource "aws_nat_gateway" "Ngw" {
    allocation_id = aws_eip.elastic_ip.id
    subnet_id = aws_subnet.private-subnet1-west-1a.id
    depends_on = [ aws_internet_gateway.Igw ]
  
}

# Create private route table
resource "aws_route_table" "private_rt_1" {
    vpc_id = aws_vpc.dev.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.Ngw.id
    }
  
}

# create route table associations for private subnets

resource "aws_route_table_association" "private_subnet1_rt" {
    subnet_id = aws_subnet.private-subnet1-west-1a.id
    route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_subnet2_rt" {
    subnet_id = aws_subnet.private-subnet2-west-1b.id
    route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_subnet3_rt" {
    subnet_id = aws_subnet.private-subnet3-west-1c.id
    route_table_id = aws_route_table.private_rt_1.id
}







