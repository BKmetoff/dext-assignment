output "public_ips" {
  description = "A list of the public EC2 instance IPs provided by the EIP"
  value       = aws_eip.eip[*].public_ip
}
