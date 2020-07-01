resource local_file client-configuration {
  filename = "${path.root}/build/client_configuration.ovpn"
  content = <<-EOF
client
dev tun
proto udp
remote ${random_id.default.hex}${trim(aws_ec2_client_vpn_endpoint.client-vpn-endpoint.dns_name, "*")} 443
remote-random-hostname
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
verb 3
<ca>
${tls_self_signed_cert.root-certificate.cert_pem}
</ca>
reneg-sec 0
<cert>
${tls_locally_signed_cert.vpn-client-certificate.cert_pem}
</cert>
<key>
${tls_private_key.vpn-client-private-key.private_key_pem}
</key>
EOF
}