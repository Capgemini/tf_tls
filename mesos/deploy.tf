# Generate a cert for each mesos machine and push it into the instances
resource "null_resource" "configure-mesos-certs" {
  count      = "${var.master_count}"

  triggers {
    master_count          = "${var.master_count}"
    mesos_private_key    = "${tls_private_key.mesos.private_key_pem}"
    mesos_certs_pem      = "${element(tls_locally_signed_cert.mesos.*.cert_pem, count.index)}"
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
      "echo '${tls_private_key.mesos.private_key_pem}' | sudo tee /etc/mesos/ssl/mesos-key.pem",
      "echo '${element(tls_locally_signed_cert.mesos.*.cert_pem, count.index)}' | sudo tee /etc/mesos/ssl/mesos.pem",
      "sudo chmod 600 /etc/mesos/ssl/mesos-key.pem",
      "sudo chmod 644 /etc/mesos/ssl/mesos.pem"
    ]
  }
}
