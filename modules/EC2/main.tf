# data "aws_caller_identity" "current" {}

resource "aws_instance" "ec2" {
  ami           = var.instance_spec.ami
  instance_type = var.instance_spec.type
  subnet_id     = var.subnet_id

  tags = {
    Name   = var.private ? "${var.name}-db" : "${var.name}-server"
    Region = var.region
  }
}
