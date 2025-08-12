locals {
  public_subnets = {
    for key, config in var.subnet_config : key => config if config.public
  }

  private_subnets = {
    for key, config in var.subnet_config : key => config if !config.public
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

###########################################################
# VPC
###########################################################

resource "aws_vpc" "here" {
  cidr_block = var.vpc_config.cidr_block

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    name = var.vpc_config.name
  }
}

###########################################################
# SUBNETS
###########################################################

resource "aws_subnet" "here" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.here.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    name = "${each.key}-${each.value.public ? "public" : "private"}"
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
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.here.id

}

resource "aws_route_table" "public" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.here.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.here[0].id
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.here[each.key].id
  route_table_id = aws_route_table.public[0].id
}

###########################################################
# NAT GATEWAY
###########################################################
# Elastic IP for NAT Gateway (only if private subnets exist)
resource "aws_eip" "nat" {
  count  = length(local.private_subnets) > 0 ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "nat-gateway-eip"
  }

  depends_on = [aws_internet_gateway.here]
}

# NAT Gateway (only if private subnets exist)
resource "aws_nat_gateway" "here" {
  count         = length(local.private_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.here[keys(local.public_subnets)[0]].id
  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.here, aws_eip.nat]
}

# Route table for private subnets (only if private subnets exist)
resource "aws_route_table" "private" {
  count  = length(local.private_subnets) > 0 ? 1 : 0
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
  for_each = local.private_subnets

  subnet_id      = aws_subnet.here[each.key].id
  route_table_id = aws_route_table.private[0].id
}
