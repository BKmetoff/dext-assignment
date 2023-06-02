data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = format("%s", var.name)
  }
}

# == public subnet ==
resource "aws_subnet" "public" {
  count = var.ec2_web_server_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  cidr_block        = var.public_subnets_cidr[count.index]

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
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
  count = var.ec2_web_server_count

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(aws_subnet.public[*].id, count.index)
}



# === private subnet ===
resource "aws_subnet" "private" {
  count = var.ec2_db_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  cidr_block        = var.private_subnets_cidr[count.index]

  tags = {
    "Name" = "private-subnet-${count.index}-${var.name}"
    "AZ"   = data.aws_availability_zones.available_zones.names[count.index]
  }
}
