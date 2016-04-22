variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}
variable "ip_addresses" {}
# supports if you have a public/private ip and you want to set the private ip
# for internal cert but use the public_ip to connect via ssh
variable "deploy_ip_addresses" {}
variable "worker_count" { default = "1" }
variable "validity_period_hours" { default = "8760" }
variable "early_renewal_hours" { default = "720" }
variable "ssh_user" { default = "core" }
variable "ssh_private_key" {}

# Kubernetes worker certs
resource "tls_private_key" "worker" {
  algorithm = "RSA"
}

resource "tls_cert_request" "worker" {
  count           = "${var.worker_count}"
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.worker.private_key_pem}"

  subject {
    common_name  = "kube-worker-${count.index}"
  }

  dns_names = [
    "*.*.cluster.internal",
    "*.ec2.internal", # ec2 only
  ]
  ip_addresses = ["${element(var.ip_addresses, count.index)}"]
}

resource "tls_locally_signed_cert" "worker" {
  count                 = "${var.worker_count}"
  cert_request_pem      = "${element(tls_cert_request.worker.*.cert_request_pem, count.index)}"
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
  value = "${tls_private_key.worker.private_key_pem}"
}
output "cert_pems" {
  value = "${join(",", tls_locally_signed_cert.worker.*.cert_pem)}"
}
