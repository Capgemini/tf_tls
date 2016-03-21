variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}
variable "ip_addresses_list" {}
variable "docker_client_count" {}
variable "private_key" {}
variable "ca_cert_pem" {}
variable "validity_period_hours" {}
variable "early_renewal_hours" {}
variable "user" {}

# docker_client certs
resource "tls_private_key" "docker_client" {
  algorithm = "RSA"
}

resource "tls_cert_request" "docker_client" {
  count           = "${var.docker_client_count}"
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.docker_client.private_key_pem}"

  subject {
    common_name  = "docker_client_${count.index}"
  }

  dns_names = [
    "*.*.cluster.internal",
    "*.ec2.internal", # ec2 only
  ]
  ip_addresses = ["${element(var.ip_addresses_list, count.index)}"]
}

resource "tls_locally_signed_cert" "docker_client" {
  count              = "${var.docker_client_count}"
  cert_request_pem   = "${element(tls_cert_request.docker_client.*.cert_request_pem, count.index)}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${var.ca_private_key_pem}"
  ca_cert_pem        = "${var.ca_cert_pem}"

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
  value = "${tls_private_key.docker_client.private_key_pem}"
}

output "cert_pems" {
  value = "${join(",", tls_locally_signed_cert.docker_client.*.cert_pem)}"
}
