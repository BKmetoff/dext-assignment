output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the private subnets in the VPC"
  value       = [for id in aws_subnet.public : id]
}


output "security_group_id" {
  description = "The IDs of the security group in the VPC"
  value       = aws_security_group.sg.id
}

output "public_key" {
  value = data.external.env.result["public_key"]
}

output "public_key_name" {
  value = aws_key_pair.ec2_key_pair.key_name
}
