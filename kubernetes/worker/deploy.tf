# Generate a cert for each worker machine and push it into the instances
resource "null_resource" "configure-worker-certs" {
  count      = "${var.worker_count}"

  triggers {
    worker_count          = "${var.worker_count}"
    worker_private_key    = "${tls_private_key.worker.private_key_pem}"
    worker_certs_pem      = "${element(tls_locally_signed_cert.worker.*.cert_pem, count.index)}"
    validity_period_hours = "${var.validity_period_hours}"
    early_renewal_hours   = "${var.early_renewal_hours}"
  }

  connection {
    user         = "${var.ssh_user}"
    private_key  = "${var.ssh_private_key}"
    host         = "${element(var.ip_addresses, count.index)}"
  }
  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /etc/kubernetes/ssl/ ]; then sudo mkdir -m 644 -p /etc/kubernetes/ssl/;fi",
      "echo '${tls_private_key.worker.private_key_pem}' | sudo tee /etc/kubernetes/ssl/worker-key.pem",
      "echo '${element(tls_locally_signed_cert.worker.*.cert_pem, count.index)}' | sudo tee /etc/kubernetes/ssl/worker.pem",
      "sudo chmod 600 /etc/kubernetes/ssl/worker-key.pem",
      "sudo chmod 644 /etc/kubernetes/ssl/worker.pem"
    ]
  }
}
