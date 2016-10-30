variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}
variable "ip_addresses_list" {}
# supports if you have a public/private ip and you want to set the private ip
# for internal cert but use the public_ip to connect via ssh
variable "deploy_ssh_hosts" {}
variable "dns_names_list" { default = "kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster.local" }
variable "docker_daemon_count" {}
variable "private_key" {}
variable "validity_period_hours" { default = 8760 }
variable "early_renewal_hours" { default = 720 }
variable "user" { default = "core" }

# docker_daemon certs
resource "tls_private_key" "docker_daemon" {
  algorithm = "RSA"
}

resource "tls_cert_request" "docker_daemon" {
  count           = "${var.docker_daemon_count}"
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.docker_daemon.private_key_pem}"

  subject {
    common_name = "docker_daemon"
  }

  dns_names = ["${split(",", var.dns_names_list)}"]
  ip_addresses = [
    "127.0.0.1",
    "${element(var.ip_addresses_list, count.index)}"
  ]
}

resource "tls_locally_signed_cert" "docker_daemon" {
  count              = "${var.docker_daemon_count}"
  cert_request_pem   = "${element(tls_cert_request.docker_daemon.*.cert_request_pem, count.index)}"
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
  value = "${tls_private_key.docker_daemon.private_key_pem}"
}
output "cert_pems" {
  value = "${join(",", tls_locally_signed_cert.docker_daemon.*.cert_pem)}"
}
