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
  for_each = toset(var.subnets)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
  subnet_id              = each.key
}

data aws_region current-region {}

resource "null_resource" "client-vpn-ingress-authorization" {
  depends_on = [aws_ec2_client_vpn_endpoint.client-vpn-endpoint]

  triggers = {
    endpoint   = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
    region     = data.aws_region.current-region.name
  }

  provisioner "local-exec" {
    when = create
    command = "aws ec2 authorize-client-vpn-ingress --region ${self.triggers.region} --client-vpn-endpoint-id ${self.triggers.endpoint} --target-network-cidr 0.0.0.0/0 --authorize-all-groups"
  }

  provisioner "local-exec"{
    when = destroy
    command = "aws ec2 revoke-client-vpn-ingress --region ${self.triggers.region} --client-vpn-endpoint-id ${self.triggers.endpoint} --target-network-cidr 0.0.0.0/0 --revoke-all-groups"
  }

  lifecycle {
    create_before_destroy = true
  }
}