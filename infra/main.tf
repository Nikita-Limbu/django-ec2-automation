# ------------------ BACKEND SETUP ------------------
terraform{
  backend "s3" {
    bucket         = "my-terraform-state-nikki-123"
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# ------------------ PROVIDER -----------------------
provider "aws" {
  region = "ap-south-1"
}

# ------------------ RANDOM ID ----------------------
# Random ID for uniqueness to force recreation
#resource "random_id" "suffix" {
#  byte_length = 4
#}

# ------------------ S3 BUCKET ----------------------
resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "my-terraform-state-nikki-123"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# ------------------ SECURITY GROUP -----------------
resource "aws_security_group" "ec2_sg" {
  name        = "djangoHW-website-ec2_sg" #${random_id.suffix.hex}
  description = "Allow SSH and HTTP access"
  vpc_id      = "vpc-f85c5890"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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
    Name = "django-helloworld-ec2-sg" #${random_id.suffix.hex}
  }
}

# ------------------ EC2 INSTANCE -------------------
resource "aws_instance" "django_instance" {
  ami                         = "ami-023a307f3d27ea427"
  instance_type               = "t3.nano"
  key_name                    = "django-hello-world-key"
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3 python3-pip git
              cd /home/ubuntu
              git clone https://github.com/Nikita-Limbu/django-ec2-automation.git
              cd django-ec2-automation
              pip3 install -r requirements.txt
              nohup python3 manage.py runserver 0.0.0.0:8000 &
            EOF

  tags = {
    Name = "Auto-HelloWorld"  #${random_id.suffix.hex}
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------ OUTPUT -------------------------
output "public_ip" {
  value = aws_instance.django_instance.public_ip
}
