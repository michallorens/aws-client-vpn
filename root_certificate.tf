resource tls_private_key root-private-key {
  algorithm = var.private_key_algorithm
}

resource tls_self_signed_cert root-certificate {
  key_algorithm     = tls_private_key.root-private-key.algorithm
  private_key_pem   = tls_private_key.root-private-key.private_key_pem
  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]

  subject {
    common_name  = var.domain_name
    organization = var.organization
  }

  validity_period_hours = var.root_certificate_validity
  early_renewal_hours   = var.root_certificate_early_renewal
}

resource aws_acm_certificate root-certificate {
  private_key      = tls_private_key.root-private-key.private_key_pem
  certificate_body = tls_self_signed_cert.root-certificate.cert_pem

  tags = merge({
    Name = "vpn-certificate-authority-${random_id.default.hex}"
  }, var.tags)
}