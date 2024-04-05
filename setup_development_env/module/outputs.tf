output "ec2_public_ip" {
  value = aws_instance.development_env_instance.public_ip
}