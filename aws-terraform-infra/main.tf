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


 provisioner "file" {
    source      = "${path.module}/dashboard/index.html"
    destination = "/home/ec2-user/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("D:/Enterprise-Multi-Cloud-Platform-AWS/key.pem")  # 
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ec2-user/index.html /var/www/html/index.html",
      "sudo systemctl restart httpd"  # If you use Apache; change if using nginx or something else
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("D:/Enterprise-Multi-Cloud-Platform-AWS/key.pem")  # Same PEM file path here
      host        = self.public_ip
    }
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

# -------------------------------
# S3 Bucket for CloudTrail Logs (with encryption and versioning)
# -------------------------------
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "oumaima-multicloud-cloudtrail-logs" 

  versioning {
    enabled = true
  }
}

# -------------------------------
# S3 Bucket Policy for CloudTrail (Allow CloudTrail to write logs)
# -------------------------------
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}"
      },
      {
        Sid       = "AWSCloudTrailWrite2"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# -------------------------------
# CloudTrail Trail
# -------------------------------
resource "aws_cloudtrail" "network_audit_trail" {
  name                          = "network-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]
}

# -------------------------------
# IAM Role for AWS Config
# -------------------------------
resource "aws_iam_role" "config_role" {
  name = "config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  # Fixed correct AWS Config managed policy ARN
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

# -------------------------------
# AWS Config Recorder & Delivery Channel
# -------------------------------
resource "aws_config_configuration_recorder" "main" {
  name     = "main"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "main"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket

  depends_on = [aws_config_configuration_recorder.main]
}

# -------------------------------
# AWS Config Rule example: required tags
# -------------------------------
resource "aws_config_config_rule" "required_tags" {
  name = "required-tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key = "Name"
  })
}

# -------------------------------
# Security Group with restricted SSH & open HTTP
# -------------------------------
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH from my IP and HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["105.71.19.44/32"] 
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_ssh_http"
  }
}
