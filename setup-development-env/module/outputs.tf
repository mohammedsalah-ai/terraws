output "ec2-public-ip" {
  value = aws_instance.t-ec2.public_ip
}