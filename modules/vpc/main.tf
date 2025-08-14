data "aws_availability_zones" "available" {
  state = "available"
}

#VPC

resource "aws_vpc" "here" {
  cidr_block = var.vpc_config.cidr_block

  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
  enable_dns_support   = var.vpc_config.enable_dns_support

  tags = {
    Name = var.vpc_config.name
  }
}

#SUBNETS

resource "aws_subnet" "public" {
  for_each          = var.public_subnet_config
  vpc_id            = aws_vpc.here.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "${each.key}-public"
  }

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.available.names, each.value.az)
      error_message = <<EOT
        The AZ "${each.value.az}" provided for the subnet "${each.key}" is not a valid AZ       in the current region.

        The applied AWS region "${data.aws_availability_zones.available.id}" supports the       following AZs:
        [${join(", ", data.aws_availability_zones.available.names)}]. 
        Please choose a valid AZ from the list above.
        EOT
    }
  }
}


resource "aws_subnet" "private" {
  for_each          = var.private_subnet_config
  vpc_id            = aws_vpc.here.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "${each.key}-private"
  }

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.available.names, each.value.az)
      error_message = <<EOT
        The AZ "${each.value.az}" provided for the subnet "${each.key}" is not a valid AZ       in the current region.

        The applied AWS region "${data.aws_availability_zones.available.id}" supports the       following AZs:
        [${join(", ", data.aws_availability_zones.available.names)}]. 
        Please choose a valid AZ from the list above.
        EOT
    }
  }
}

resource "aws_internet_gateway" "here" {
  count  = length(aws_subnet.public) > 0 ? 1 : 0
  vpc_id = aws_vpc.here.id

}

resource "aws_route_table" "public" {
  count  = length(aws_subnet.public) > 0 ? 1 : 0
  vpc_id = aws_vpc.here.id

  tags = {
    Name = "private-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.here[0].id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

###########################################################
# NAT GATEWAY
###########################################################
# Elastic IP for NAT Gateway (only if private subnets exist)
resource "aws_eip" "nat" {
  count  = length(aws_subnet.private) > 0 ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "nat-gateway-eip"
  }

  depends_on = [aws_internet_gateway.here]
}

# NAT Gateway (only if private subnets exist)
resource "aws_nat_gateway" "here" {
  count         = length(aws_subnet.private) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.private)[0].id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.here, aws_eip.nat]
}

# Route table for private subnets (only if private subnets exist)
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private) > 0 ? 1 : 0
  vpc_id = aws_vpc.here.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.here[0].id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[0].id
}
