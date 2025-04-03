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

# Automatically create and deploy a new EC2 instance
resource "aws_instance" "django_instance" {
  ami             = "ami-023a307f3d27ea427"   # Use an appropriate AMI for your region
  instance_type   = "t3.nano"
  key_name        = "django-hello-world-key"  # Your existing key pair
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # This script runs when the instance starts
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y python3 python3-pip
    sudo apt install -y git
    git clone https://github.com/Nikita-Limbu/django-ec2-automation.git /home/ubuntu/django-app
    cd /home/ubuntu/django-app
    pip3 install -r requirements.txt
    nohup python3 manage.py runserver 0.0.0.0:8000 &
  EOF

  tags = {
    Name = "DjangoHelloWorld-Auto"
  }
}

output "public_ip" {
  value = aws_instance.django_instance.public_ip
}
