output "public_instance_ip" {
  description = "Public IP of the EC2 instance in the public subnet"
  value       = aws_instance.ec2_public.public_ip
}

output "private_instance_ip" {
  description = "Private IP of the EC2 instance in the private subnet"
  value       = aws_instance.ec2_private.private_ip
}
