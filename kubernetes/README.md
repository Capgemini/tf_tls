Kubernetes TLS terraform module
=======================

A terraform module with contains TLS certificates for Kubernetes master, worker
and admin key.

Certs
-----
- /etc/kubernetes/ssl/worker-key.pem (Worker private key)
- /etc/kubernetes/ssl/worker.pem (Worker PEM)
- /etc/kubernetes/ssl/apiserver-key.pem (APIserver private key)
- /etc/kubernetes/ssl/apiserver.pem (APIserver PEM)

Usage
-----

You can use these in your terraform template with the following steps.

1. Adding a module resource to your template, e.g. `main.tf`

```
module "k8s_worker" {
  source                = "github.com/Capgemini/tf_tls/kubernetes/worker"
  ip_addresses          = "10.0.0.1,10.0.0.2" # IP addresses of instances to configure with certs
  ca_cert_pem           = "/ca/cert_pem" # CA cert PEM
  ca_private_key_pem    = "/ca/private_key" # CA private key
  worker_count          = 1 # number of worker instances
  validity_period_hours = "8760" # hours of cert validity
  early_renewal_hours"  = "720" # hours of cert renewal
  ssh_user              = "core" # ssh user for ip_addresses
  ssh_private_key"      = "/ssh/private_key" # ssh private key for ip_addresses

}

module "k8s_admin" {
  source                = "github.com/Capgemini/tf_tls/kubernetes/worker"
  ip_addresses          = "10.0.0.1,10.0.0.2" # IP addresses of instances to configure with certs
  ca_cert_pem           = "/ca/cert_pem" # CA cert PEM
  ca_private_key_pem    = "/ca/private_key" # CA private key
  worker_count          = 1 # number of worker instances
  validity_period_hours = "8760" # hours of cert validity
  early_renewal_hours"  = "720" # hours of cert renewal
  ssh_user              = "core" # ssh user for ip_addresses
  ssh_private_key"      = "/ssh/private_key" # ssh private key for ip_addresses
}

```
