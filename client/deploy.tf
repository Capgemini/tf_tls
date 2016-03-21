resource "null_resource" "configure-docker-client-certs" {
  count      = "${var.docker_client_count}"
  # Changes to the number of masters/workers triggers the provisioner again across
  # all instances.
  triggers {
    docker_client_count       = "${var.docker_client_count}"
    docker_client_private_key = "${tls_private_key.docker_client.private_key_pem}"
    docker_client_certs_pem   = "${element(tls_locally_signed_cert.docker_client.*.cert_pem, count.index)}"
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
      "if [ ! -d '~/.docker' ]; then mkdir ~/.docker;fi",
      "echo '${var.ca_cert_pem}' | sudo tee ~/.docker/ca.pem",
      "echo '${tls_private_key.docker_client.private_key_pem}' | sudo tee ~/.docker/key.pem",
      "echo '${element(tls_locally_signed_cert.docker_client.*.cert_pem, count.index)}' | sudo tee ~/.docker/cert.pem",
      "sudo chmod 644 /home/${var.user}/.docker/ca.pem",
      "sudo chmod 600 /home/${var.user}/.docker/key.pem",
      "sudo chmod 644 /home/${var.user}/.docker/cert.pem",
      "sudo chown ${var.user}:${var.user} /home/${var.user}/.docker/*"
    ]
  }
}
