resource "aws_security_group" "here" {
  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id
  description = "Managed Security Group"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_ipv4" {
  description       = "Allows all outbound traffic"
  count             = var.allow_all_egress ? 1 : 0
  security_group_id = aws_security_group.here.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group_rule" "custom" {
  for_each    = var.security_group_config
  description = each.value.description

  security_group_id = aws_security_group.here.id


  type        = each.value.type
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks

}
