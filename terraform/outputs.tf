output "ec2_public_ip" {
  value = aws_instance.ansible_ec2.public_ip
  description = "Public IP of the EC2 instance"
}