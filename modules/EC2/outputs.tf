output "public_ips" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = aws_eip.eip.public_ip
}

output "ec2_instance_id" {
  description = "The ID of the ec2 instance"
  value       = aws_instance.ec2.arn
}
