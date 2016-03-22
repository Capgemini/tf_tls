variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}
variable "master_count" {}
variable "validity_period_hours" { default = "8760" }
variable "early_renewal_hours" { default = "720" }
variable "ssh_user" { default = "core" }
variable "ssh_private_key" {}

# Mesos certs
resource "tls_private_key" "mesos" {
  algorithm = "RSA"
}

resource "tls_cert_request" "mesos" {
  count           = "${var.master_count}"
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.mesos.private_key_pem}"

  subject {
    common_name = "apollo-mesos"
  }

}

resource "tls_locally_signed_cert" "mesos" {
  count                 = "${var.master_count}"
  cert_request_pem      = "${element(tls_cert_request.mesos.*.cert_request_pem, count.index)}"
  ca_key_algorithm      = "RSA"
  ca_private_key_pem    = "${var.ca_private_key_pem}"
  ca_cert_pem           = "${var.ca_cert_pem}"
  validity_period_hours = "${var.validity_period_hours}"
  early_renewal_hours   = "${var.early_renewal_hours}"

  allowed_uses = [
    "server_auth",
    "client_auth",
    "digital_signature",
    "key_encipherment"
  ]
}

output "private_key" {
  value = "${tls_private_key.mesos.private_key_pem}"
}
output "cert_pems" {
  value = "${join(",", tls_locally_signed_cert.mesos.*.cert_pem)}"
}
