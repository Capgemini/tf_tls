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


Usage
-----

```
module "ca" {
  source                = "../certs/ca"
  validity_period_hours = 240000
  early_renewal_hours   = 720
  is_ca_certificate     = true
  common_name           = "kube-ca"
  organization          = "Apollo"
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

