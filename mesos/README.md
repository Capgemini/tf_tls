Mesos TLS terraform module
=======================

A terraform module with contains TLS certificates for Mesos master, agent and frameworks
and admin key.

Certs
-----
- /etc/mesos/ssl/mesos-key.pem (Worker private key)
- /etc/mesos/ssl/mesos.pem (Worker PEM)

Usage
-----

You can use these in your terraform template with the following steps.

1. Adding a module resource to your template, e.g. `main.tf`

```
module "k8s_worker" {
  source                = "github.com/Capgemini/tf_tls/mesos"
  ca_cert_pem           = "/ca/cert_pem" # CA cert PEM
  ca_private_key_pem    = "/ca/private_key" # CA private key
  validity_period_hours = "8760" # hours of cert validity
  early_renewal_hours"  = "720" # hours of cert renewal
  ssh_user              = "core" # ssh user for ip_addresses
  ssh_private_key"      = "/ssh/private_key" # ssh private key for ip_addresse
}

```
