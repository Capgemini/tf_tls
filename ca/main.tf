variable "organization" { default = "apollo" }
# valid for 1000 days
variable "validity_period_hours" { default = 240000 }
variable "early_renewal_hours" { default = 720 }
variable "is_ca_certificate" { default = true }
variable "common_name" { default = "kube-ca" }

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name  = "${var.common_name}"
    organization = "${var.organization}"
  }

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]

  validity_period_hours = "${var.validity_period_hours}"
  early_renewal_hours   = "${var.early_renewal_hours}"
  is_ca_certificate     = "${var.is_ca_certificate}"
}

output "ca_cert_pem" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}
output "ca_private_key_pem" {
  value = "${tls_private_key.ca.private_key_pem}"
}
