# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "multi-cloud-vpc"
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "multi-cloud-igw"
  }
}

# -------------------------------
# Public Subnet
# -------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# -------------------------------
# Private Subnet
# -------------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "private-subnet"
  }
}

# -------------------------------
# Public Route Table
# -------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# -------------------------------
# Route Table Association
# -------------------------------
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------------------
# EC2 Public Instance
# -------------------------------
resource "aws_instance" "ec2_public" {
  ami                         = "ami-01032886170466a16"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = "oumaima-key"

  tags = {
    Name = "public-ec2-1"
  }
}

# -------------------------------
# EC2 Private Instance
# -------------------------------
resource "aws_instance" "ec2_private" {
  ami           = "ami-01032886170466a16"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = "oumaima-key"

  tags = {
    Name = "private-ec2-1"
  }
}
