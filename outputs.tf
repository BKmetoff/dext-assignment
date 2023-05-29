output "security_group_id" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = module.vpc.security_group_id
}

output "ec2_eip_public_ips" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = flatten(module.ec2_web_server[*].public_ips)
}

output "ec2_public_key" {
  value = module.vpc.public_key
}
