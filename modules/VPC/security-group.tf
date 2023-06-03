locals {
  egress = [
    {
      description      = "Allow all outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  # Expose ports 80 and 81 to allow incoming traffic
  # to both 'wordpress' replicas started by docker-compose.
  # See /docker/docker-compose.yaml
  ingress_rules_web_server = [
    {
      name        = "HTTPS"
      port        = 443
      description = "Ingress rules for port 443"
    },
    {
      name        = "HTTP"
      port        = 80
      description = "Ingress rules for port 80"
    },
    {
      name        = "HTTP"
      port        = 81
      description = "Ingress rules for port 81"
    },
    {
      name        = "SSH"
      port        = 22
      description = "Ingress rules for port 22"
    }
  ]
}

resource "aws_security_group" "web_server" {
  name        = "web-server-${var.name}-sg"
  description = "Allow TLS inbound traffic"

  vpc_id = aws_vpc.vpc.id

  egress = local.egress

  dynamic "ingress" {
    for_each = local.ingress_rules_web_server

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    "Name"     = "sg-group-web-${var.name}"
    "Inbound"  = "HTTP, HTTPS, SSH"
    "Outbound" = "All"
  }
}
