resource random_id default {
  byte_length = 8
}

resource aws_cloudwatch_log_group client-vpn-log-group {
  name = "/aws/client-vpn-endpoint/${random_id.default.hex}"

  retention_in_days = var.log_retention
}

resource aws_cloudwatch_log_stream client-vpn-log-stream {
  name           = "client-vpn-endpoint-${random_id.default.hex}"
  log_group_name = aws_cloudwatch_log_group.client-vpn-log-group.name
}

resource aws_ec2_client_vpn_endpoint client-vpn-endpoint {
  server_certificate_arn = aws_acm_certificate.vpn-server-certificate.arn
  client_cidr_block      = var.cidr
  tags                   = var.tags

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn-client-certificate.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client-vpn-log-group.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.client-vpn-log-stream.name
  }
}

resource aws_ec2_client_vpn_network_association client-vpn-subnet-assocation {
  for_each = var.subnets

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
  subnet_id              = each.key
}

resource aws_ec2_client_vpn_authorization_rule client-vpn-authorization {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
  target_network_cidr    = var.destination_cidr
  authorize_all_groups   = true
}

resource aws_ec2_client_vpn_route client_vpn_route {
  for_each = var.subnets

  destination_cidr_block = var.destination_cidr
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
  target_vpc_subnet_id   = each.key
}