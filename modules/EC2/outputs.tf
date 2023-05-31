output "public_ips" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = [for eip in aws_eip.eip : eip.public_ip]
}
