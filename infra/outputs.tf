 output "ec2_ip" {
  value = aws_instance.django_instance.public_ip
}

