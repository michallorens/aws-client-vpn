resource tls_private_key vpn-client-private-key {
  algorithm = var.private_key_algorithm
}

resource tls_cert_request vpn-client-certificate-request {
  key_algorithm   = tls_private_key.vpn-client-private-key.algorithm
  private_key_pem = tls_private_key.vpn-client-private-key.private_key_pem

  subject {
    common_name  = var.domain_name
    organization = var.organization
  }
}

resource tls_locally_signed_cert vpn-client-certificate {
  cert_request_pem   = tls_cert_request.vpn-client-certificate-request.cert_request_pem
  ca_key_algorithm   = tls_private_key.root-private-key.algorithm
  ca_private_key_pem = tls_private_key.root-private-key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root-certificate.cert_pem

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth"
  ]

  validity_period_hours = var.client_certificate_validity
}

resource aws_acm_certificate vpn-client-certificate {
  private_key       = tls_private_key.vpn-client-private-key.private_key_pem
  certificate_body  = tls_locally_signed_cert.vpn-client-certificate.cert_pem
  certificate_chain = tls_self_signed_cert.root-certificate.cert_pem

  tags = merge({
    Name = "vpn-client-certificate-${random_id.default.hex}"
  }, var.tags)
}