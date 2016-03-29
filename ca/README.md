ca
==========
A Terraform module for creating a self signed CA in order to locally sign certificates and create secure communication on TLS between software components.

Input Variables
---------------

`organization` - Organization name for the subject for which a certificate is being requested.

`validity_period_hours` - https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#validity_period_hours

`early_renewal_hours` - https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#early_renewal_hours

`is_ca_certificate` - https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#is_ca_certificate

`common_name` - Name for the subject for which a certificate is being requested.

`ca_count` - Number of servers to upload the CA.

`ip_addresses_list` - Host list to upload the CA.

`ssh_user` - User to ssh into the hosts.

`ssh_private_key` - Private key to ssh into the hosts. 

`target_folder` - Folder to upload the the CA.

`user` - User for the target folder.


Usage
-----

```
module "ca" {
  source                = "github.com/Capgemini/tf_tls//ca"
  validity_period_hours = 240000
  early_renewal_hours   = 720
  is_ca_certificate     = true
  common_name           = "kube-ca"
  organization          = "Apollo"
  ca_count          	= "${var.masters + var.workers}"
  ip_addresses_list     = "${concat(digitalocean_droplet.master.*.ipv4_address, digitalocean_droplet.worker.*.ipv4_address)}"
  ssh_private_key       = "${tls_private_key.ssh.private_key_pem}"
}
```

Outputs
-------

```
output "ca_cert_pem" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}

output "ca_private_key_pem" {
  value = "${tls_private_key.ca.private_key_pem}"
}
```

