provider "aws" {
  region = "ap-south-1"  # Replace with your region
}

# Use the existing PEM key
resource "aws_instance" "django_instance" {
  ami             = "ami-023a307f3d27ea427"     # AMI ID
  instance_type   = "t3.nano"                
  key_name        = "django-hello-world-key"    # Your existing key name (without .pem extension)
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "Automation_DjangoHelloWorld"
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
      private_key = file("./ec2-key.pem")    # Use your .pem key
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.django_instance.public_ip
}
