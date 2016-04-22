resource "null_resource" "configure-apiserver-certs" {
  count      = "${var.master_count}"

  triggers {
    master_count          = "${var.master_count}"
    apiserver_private_key = "${tls_private_key.apiserver.private_key_pem}"
    apiserver_certs_pem   = "${element(tls_locally_signed_cert.apiserver.*.cert_pem, count.index)}"
    validity_period_hours = "${var.validity_period_hours}"
    early_renewal_hours   = "${var.early_renewal_hours}"
  }

  connection {
    user         = "${var.ssh_user}"
    private_key  = "${var.ssh_private_key}"
    host         = "${element(var.deploy_ip_addresses, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /etc/kubernetes/ssl/ ]; then sudo mkdir -m 644 -p /etc/kubernetes/ssl/;fi",
      "echo '${tls_private_key.apiserver.private_key_pem}' | sudo tee /etc/kubernetes/ssl/apiserver-key.pem",
      "echo '${element(tls_locally_signed_cert.apiserver.*.cert_pem, count.index)}' | sudo tee /etc/kubernetes/ssl/apiserver.pem",
      "sudo chmod 600 /etc/kubernetes/ssl/apiserver-key.pem",
      "sudo chmod 644 /etc/kubernetes/ssl/apiserver.pem"
    ]
  }
}
