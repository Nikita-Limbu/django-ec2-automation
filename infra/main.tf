provider "aws" {
  region = "ap-south-1"
}

# Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "djangoHW-website-ec2_sg"  # Updated name 
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
    Name = "django-helloworld-ec2-sg"
  }
}

# EC2 instance that auto-deploys the Django Hello World app
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
    Name = "Auto-HelloWorld"
  }
}

# Output the public IP
output "public_ip" {
  value = aws_instance.django_instance.public_ip
}
