output "web_server_security_group_id" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = module.vpc.web_server_security_group_id
}

output "ec2_web_public_ips" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = flatten([for ec2 in module.ec2_web_server : ec2.public_ips])
}

# output "ec2_public_key" {
#   value = module.vpc.public_key
# }
