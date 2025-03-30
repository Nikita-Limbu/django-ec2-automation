provider "aws" {
  region = "ap-south-1"
}

# Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "django-sg"
  description = "Allow SSH and HTTP access"
  
  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "django-ec2-sg"
  }
}

# EC2 instance configuration
resource "aws_instance" "django_instance" {
  ami             = "ami-0e670eb768a5fc3d4"   # Replace with latest AMI
  instance_type   = "t3.nano"
  key_name        = "django-hello-world-key"              # AWS key pair name
  security_groups = [aws_security_group.ec2_sg.name]      # Reference the SG properly

  tags = {
    Name = "DjangoHelloWorld"
  }

  # Provisioning commands
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io docker-compose",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 8000:8000 nikitalimbu/helloworld-django:latest"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./EC2_SSH_KEY.pem")    # References the key saved from the GitHub secret
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.django_instance.public_ip
}
