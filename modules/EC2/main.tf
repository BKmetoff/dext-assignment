resource "aws_instance" "ec2" {
  ami                    = var.instance_spec.ami
  instance_type          = var.instance_spec.type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  key_name = var.ec2_public_key

  tags = {
    Name   = "${var.name}-server"
    Region = var.region
  }
}

resource "aws_eip" "eip" {
  instance         = aws_instance.ec2.id
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = { "Name" = "elastic-ip-${var.name}" }
}

resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.eip.id
}
