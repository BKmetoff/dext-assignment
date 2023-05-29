data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = {
    "Name" = format("%s", var.name)
  }
}

resource "aws_subnet" "public" {
  count = var.ec2_web_server_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  cidr_block        = element(cidrsubnets(var.cidr, 8, 4, 4), count.index)

  tags = {
    "Name" = "public-subnet-${count.index}-${var.name}"
    "AZ"   = data.aws_availability_zones.available_zones.names[count.index]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "igw-${var.name}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "public-route-table-${var.name}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
  count = var.ec2_web_server_count

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(aws_subnet.public[*].id, count.index)
}


