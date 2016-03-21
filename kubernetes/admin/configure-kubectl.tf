resource "null_resource" "configure-kubectl" {
  triggers {
    ca_pem                = "${var.ca_cert_pem}"
    admin_private_key     = "${tls_private_key.kube-admin.private_key_pem}"
    admin_certs_pem       = "${tls_locally_signed_cert.kube-admin.cert_pem}"
    validity_period_hours = "${var.validity_period_hours}"
    early_renewal_hours   = "${var.early_renewal_hours}"
  }

  # export certificates for kubectl
  provisioner "local-exec" {
    command = "echo '${var.ca_cert_pem}' | tee ${path.module}/ca.pem && chmod 644 ${path.module}/ca.pem"
  }
  provisioner "local-exec" {
    command = "echo '${tls_locally_signed_cert.kube-admin.cert_pem}' | tee ${path.module}/admin.pem && chmod 644 ${path.module}/admin.pem"
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.kube-admin.private_key_pem}' | tee ${path.module}/admin-key.pem && chmod 600 ${path.module}/admin-key.pem"
  }

  # setup kubectl
  provisioner "local-exec" {
    command = "${var.kubectl} config set-cluster default-cluster --server=https://${var.kubectl_server_ip} --certificate-authority=${path.module}/ca.pem"
  }
  provisioner "local-exec" {
    command = "${var.kubectl} config set-credentials default-admin --certificate-authority=${path.module}/ca.pem --client-key=${path.module}/admin-key.pem --client-certificate=${path.module}/admin.pem"
  }
  provisioner "local-exec" {
    command = "${var.kubectl} config set-context default-system --cluster=default-cluster --user=default-admin"
  }
  provisioner "local-exec" {
    command = "${var.kubectl} config use-context default-system"
  }
}
