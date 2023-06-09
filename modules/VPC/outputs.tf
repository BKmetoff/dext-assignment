output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets in the VPC"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "web_server_security_group_id" {
  description = "The ID of the security group the web servers should be associated with"
  value       = aws_security_group.web_server.id
}

output "public_key" {
  value = data.external.env.result["public_key"]
}

output "public_key_name" {
  value = aws_key_pair.ec2_key_pair.key_name
}
