# Generate a cert for each kubelet machine and push it into the instances
resource "null_resource" "configure-kubelet-certs" {
  count      = "${var.kubelet_count}"

  triggers {
    kubelet_count          = "${var.kubelet_count}"
    kubelet_private_key    = "${tls_private_key.kubelet.private_key_pem}"
    kubelet_certs_pem      = "${element(tls_locally_signed_cert.kubelet.*.cert_pem, count.index)}"
    validity_period_hours = "${var.validity_period_hours}"
    early_renewal_hours   = "${var.early_renewal_hours}"
  }

  connection {
    user         = "${var.ssh_user}"
    private_key  = "${var.ssh_private_key}"
    host         = "${element(var.deploy_ssh_hosts, count.index)}"
  }
  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /etc/kubernetes/ssl/ ]; then sudo mkdir -m 644 -p /etc/kubernetes/ssl/;fi",
      "echo '${tls_private_key.kubelet.private_key_pem}' | sudo tee /etc/kubernetes/ssl/kubelet-key.pem",
      "echo '${element(tls_locally_signed_cert.kubelet.*.cert_pem, count.index)}' | sudo tee /etc/kubernetes/ssl/kubelet.pem",
      "sudo chmod 600 /etc/kubernetes/ssl/kubelet-key.pem",
      "sudo chmod 644 /etc/kubernetes/ssl/kubelet.pem"
    ]
  }
}
