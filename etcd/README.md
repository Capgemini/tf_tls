Etcd TLS terraform module
=======================

A terraform module with contains TLS certificates for etcd.

Usage
-----

You can use these in your terraform template with the following steps.

1. Adding a module resource to your template, e.g. `main.tf`

```
module "etcd" {
  source                = "github.com/Capgemini/tf_tls/etcd"
  ca_cert_pem           = "/ca/cert_pem" # CA cert PEM
  ca_private_key_pem    = "/ca/private_key" # CA private key
  validity_period_hours = "8760" # hours of cert validity
  early_renewal_hours"  = "720" # hours of cert renewal
}
```

Outputs
-------
- ```etcd_cert_pem``` - etcd cert PEM
- ```etcd_private_key``` - etcd private key
