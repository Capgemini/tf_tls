resource "null_resource" "configure-docker-dameon-certs" {
  count      = "${var.docker_daemon_count}"
  # Changes to the number of masters/workers triggers the provisioner again across
  # all instances.
  triggers {
    docker_daemon_count       = "${var.docker_daemon_count}"
    docker_daemon_private_key = "${tls_private_key.docker_daemon.private_key_pem}"
    docker_daemon_certs_pem   = "${element(tls_locally_signed_cert.docker_daemon.*.cert_pem, count.index)}"
    validity_period_hours     = "${var.validity_period_hours}"
    early_renewal_hours       = "${var.early_renewal_hours}"
  }

  connection {
    user         = "${var.user}"
    private_key  = "${var.private_key}"
    host         = "${element(var.ip_addresses_list, count.index)}"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '${var.ca_cert_pem}' | sudo tee /etc/docker/ca.pem",
      "echo '${tls_private_key.docker_daemon.private_key_pem}' | sudo tee /etc/docker/server-key.pem",
      "echo '${element(tls_locally_signed_cert.docker_daemon.*.cert_pem, count.index)}' | sudo tee /etc/docker/server.pem",
      "sudo chmod 644 /etc/docker/ca.pem",
      "sudo chmod 600 /etc/docker/server-key.pem",
      "sudo chmod 644 /etc/docker/server.pem"
    ]
  }
}
