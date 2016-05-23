resource "null_resource" "configure-master-certs" {
  count      = "${var.master_count}"

  triggers {
    master_count          = "${var.master_count}"
    master_private_key    = "${tls_private_key.master.private_key_pem}"
    master_certs_pem      = "${element(tls_locally_signed_cert.master.*.cert_pem, count.index)}"
    validity_period_hours = "${var.validity_period_hours}"
    early_renewal_hours   = "${var.early_renewal_hours}"
    dns_names             = "${var.dns_names}"
    ip_addresses           = "${join(",",var.ip_addresses)}"
    deploy_ssh_hosts       = "${join(",",var.deploy_ssh_hosts)}"
  }

  connection {
    user         = "${var.ssh_user}"
    private_key  = "${var.ssh_private_key}"
    host         = "${element(var.deploy_ssh_hosts, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /etc/kubernetes/ssl/ ]; then sudo mkdir -m 644 -p /etc/kubernetes/ssl/;fi",
      "echo '${tls_private_key.master.private_key_pem}' | sudo tee /etc/kubernetes/ssl/master-key.pem",
      "echo '${element(tls_locally_signed_cert.master.*.cert_pem, count.index)}' | sudo tee /etc/kubernetes/ssl/master.pem",
      "sudo chmod 600 /etc/kubernetes/ssl/master-key.pem",
      "sudo chmod 644 /etc/kubernetes/ssl/master.pem"
    ]
  }
}
