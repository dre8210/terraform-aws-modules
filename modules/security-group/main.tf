resource "aws_security_group" "public" {
  name_prefix = var.public_name_prefix
  vpc_id      = var.vpc_id
  description = "Public Security Group"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_ipv4" {
  description       = "Allows all outbound traffic"
  count             = var.public_allow_all_egress ? 1 : 0
  security_group_id = aws_security_group.public
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group_rule" "public" {
  for_each    = var.security_group_config_public
  description = each.value.description

  security_group_id = aws_security_group.public.id


  type        = each.value.type
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks

}

resource "aws_security_group" "private" {
  name_prefix = var.private_name_prefix
  vpc_id      = var.vpc_id
  description = "Private Security Group"
}

resource "aws_security_group_rule" "private" {
  for_each    = var.security_group_config_private
  description = each.value.description

  security_group_id = aws_security_group.private.id


  type        = each.value.type
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
}
