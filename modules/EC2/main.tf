resource "aws_instance" "ec2" {
  ami                    = var.instance_spec.ami
  instance_type          = var.instance_spec.type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  key_name = var.ec2_public_key

  tags = {
    Name   = var.private ? "${var.name}-db" : "${var.name}-server"
    Region = var.region
  }
}

resource "aws_eip" "eip" {
  count = length(aws_instance.ec2[*].id)

  instance         = element(aws_instance.ec2[*].id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = { "Name" = "elastic-ip-${count.index}-${var.name}" }
}

resource "aws_eip_association" "eip_association" {
  count = length(aws_eip.eip)

  instance_id   = element(aws_instance.ec2[*].id, count.index)
  allocation_id = element(aws_eip.eip[*].id, count.index)
}
