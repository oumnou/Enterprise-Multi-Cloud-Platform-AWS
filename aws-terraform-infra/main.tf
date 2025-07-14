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

# -------------------------------
# IAM Users
# -------------------------------
resource "aws_iam_user" "oumaima" {
  name = "oumaima.admin"
}

resource "aws_iam_user" "marouane" {
  name = "marouane.dev"
}

resource "aws_iam_user" "sara" {
  name = "sara.analyst"
}

resource "aws_iam_user" "laila" {
  name = "laila.intern"
}

# -------------------------------
# IAM Groups
# -------------------------------
resource "aws_iam_group" "admins" {
  name = "admins"
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group" "analysts" {
  name = "analysts"
}

resource "aws_iam_group" "interns" {
  name = "interns"
}

# -------------------------------
# Add Users to Groups
# -------------------------------
resource "aws_iam_user_group_membership" "oumaima_membership" {
  user   = aws_iam_user.oumaima.name
  groups = [aws_iam_group.admins.name]
}

resource "aws_iam_user_group_membership" "marouane_membership" {
  user   = aws_iam_user.marouane.name
  groups = [aws_iam_group.developers.name]
}

resource "aws_iam_user_group_membership" "sara_membership" {
  user   = aws_iam_user.sara.name
  groups = [aws_iam_group.analysts.name]
}

resource "aws_iam_user_group_membership" "laila_membership" {
  user   = aws_iam_user.laila.name
  groups = [aws_iam_group.interns.name]
}

# -------------------------------
# Attach Managed Policies to Groups
# -------------------------------
resource "aws_iam_group_policy_attachment" "admin_policy" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "developer_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "analyst_policy" {
  group      = aws_iam_group.analysts.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_group_policy_attachment" "intern_policy" {
  group      = aws_iam_group.interns.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# -------------------------------
# IAM Access Keys for Users
# -------------------------------
resource "aws_iam_access_key" "oumaima_key" {
  user = aws_iam_user.oumaima.name
}

resource "aws_iam_access_key" "marouane_key" {
  user = aws_iam_user.marouane.name
}

resource "aws_iam_access_key" "sara_key" {
  user = aws_iam_user.sara.name
}

resource "aws_iam_access_key" "laila_key" {
  user = aws_iam_user.laila.name
}

# -------------------------------
# Outputs for IAM Access Keys (Sensitive)
# -------------------------------
output "oumaima_access_key_id" {
  value     = aws_iam_access_key.oumaima_key.id
  sensitive = true
}

output "oumaima_secret_access_key" {
  value     = aws_iam_access_key.oumaima_key.secret
  sensitive = true
}

output "marouane_access_key_id" {
  value     = aws_iam_access_key.marouane_key.id
  sensitive = true
}

output "marouane_secret_access_key" {
  value     = aws_iam_access_key.marouane_key.secret
  sensitive = true
}

output "sara_access_key_id" {
  value     = aws_iam_access_key.sara_key.id
  sensitive = true
}

output "sara_secret_access_key" {
  value     = aws_iam_access_key.sara_key.secret
  sensitive = true
}

output "laila_access_key_id" {
  value     = aws_iam_access_key.laila_key.id
  sensitive = true
}

output "laila_secret_access_key" {
  value     = aws_iam_access_key.laila_key.secret
  sensitive = true
}
