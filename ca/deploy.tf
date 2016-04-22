resource "null_resource" "deploy-ca-certs" {
  count      = "${var.ca_count}"
  # Changes to the number of masters/workers triggers the provisioner again across
  # all instances.
  triggers {
    ca_count              = "${var.ca_count}"
    ca_cert_pem           = "${tls_self_signed_cert.ca.cert_pem}"
    validity_period_hours = "${var.validity_period_hours}"
    early_renewal_hours   = "${var.early_renewal_hours}"
    ip_addresses_list     = "{$var.ip_addresses_list}"
    common_name           = "{$var.common_name}"
  }

  connection {
    user         = "${var.ssh_user}"
    private_key  = "${var.ssh_private_key}"
    host         = "${element(var.deploy_ip_addresses, count.index)}"
  }
  provisioner "remote-exec" {
    inline = [
      "if [ ! -d ${var.target_folder} ]; then sudo mkdir -m 644 -p ${var.target_folder};fi",
      "sudo chown ${var.user}:${var.user} ${var.target_folder}",
      "echo '${tls_self_signed_cert.ca.cert_pem}' | sudo tee ${var.target_folder}/ca.pem",
      "echo '${tls_private_key.ca.private_key_pem}' | sudo tee ${var.target_folder}/ca-key.pem",
      "sudo chmod 644 ${var.target_folder}/ca.pem",
      "sudo chmod 600 ${var.target_folder}/ca-key.pem"
    ]
  }
}
