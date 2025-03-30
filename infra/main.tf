provider "aws" {
  region = "ap-south-1"
}

# Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "django-sg-auto"
  description = "Allow SSH and HTTP access"
  
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
    Name = "django-ec2-sg-auto"
  }
}

# EC2 instance configuration
resource "aws_instance" "django_instance" {
  ami             = "ami-023a307f3d27ea427"   # latest AMI
  instance_type   = "t3.nano"
  key_name        = "django-hello-world-key"   # Use your AWS key pair name
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "DjangoHelloWorld"
  }
}

output "public_ip" {
  value = aws_instance.django_instance.public_ip
}
