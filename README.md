tf_tls
======================

<a href="https://app.wercker.com/project/bykey/edc95e9edaf6ff8223d19026b6ca6a22"><img alt="Wercker status" src="https://app.wercker.com/status/edc95e9edaf6ff8223d19026b6ca6a22/m"></a>

A Terraform module which contains a number of common configurations for TLS certificates.

TLS Catalog
------------
- [ca](https://github.com/Capgemini/tf_tls/tree/master/ca)
    - Self signed CA to locally sign TLS certs.
- [docker](https://github.com/Capgemini/tf_tls/tree/master/docker)
    - TLS certs for Docker daemon and client
- [kubernetes](https://github.com/Capgemini/tf_tls/tree/master/kubernetes)
    - TLS certs for APIserver, worker and admin key
- [etcd](https://github.com/Capgemini/tf_tls/tree/master/etcd)
    - TLS certs etcd

Usage
------

You can refer to the specific readme for every catalog element for checking individual use. 

For a real use case using them all together in a kubernetes cluster on Digitalocean see https://github.com/Capgemini/kubeform/blob/master/terraform/digitalocean/main.tf

```
module "ca" {
  source            = "github.com/Capgemini/tf_tls//ca"
  organization      = "${var.organization}"
  ca_count          = "${var.masters + var.workers}"
  ip_addresses_list = "${concat(digitalocean_droplet.master.*.ipv4_address, digitalocean_droplet.worker.*.ipv4_address)}"
  ssh_user          = "core"
  ssh_private_key   = "${tls_private_key.ssh.private_key_pem}"
}

module "kube_apiserver_certs" {
  source                = "github.com/Capgemini/tf_tls//kubernetes/apiserver"
  ca_cert_pem           = "${module.ca.ca_cert_pem}"
  ca_private_key_pem    = "${module.ca.ca_private_key_pem}"
  ip_addresses          = "${compact(digitalocean_droplet.master.*.ipv4_address)}"
  master_count          = "${var.masters}"
  validity_period_hours = "8760"
  early_renewal_hours   = "720"
  ssh_user              = "core"
  ssh_private_key       = "${tls_private_key.ssh.private_key_pem}"
}

module "kube_worker_certs" {
  source                = "github.com/Capgemini/tf_tls//kubernetes/worker"
  ca_cert_pem           = "${module.ca.ca_cert_pem}"
  ca_private_key_pem    = "${module.ca.ca_private_key_pem}"
  ip_addresses          = "${compact(digitalocean_droplet.worker.*.ipv4_address)}"
  worker_count          = "${var.workers}"
  validity_period_hours = "8760"
  early_renewal_hours   = "720"
  ssh_user              = "core"
  ssh_private_key       = "${tls_private_key.ssh.private_key_pem}"
}

module "kube_admin_cert" {
  source                = "github.com/Capgemini/tf_tls/kubernetes/admin"
  ca_cert_pem           = "${module.ca.ca_cert_pem}"
  ca_private_key_pem    = "${module.ca.ca_private_key_pem}"
  kubectl_server_ip     = "${digitalocean_droplet.master.0.ipv4_address}"
}

module "docker_daemon_certs" {
  source                = "github.com/Capgemini/tf_tls//docker/daemon"
  ca_cert_pem           = "${module.ca.ca_cert_pem}"
  ca_private_key_pem    = "${module.ca.ca_private_key_pem}"
  ip_addresses_list     = "${concat(digitalocean_droplet.master.*.ipv4_address, digitalocean_droplet.worker.*.ipv4_address)}"
  docker_daemon_count   = "${var.masters + var.workers}"
  private_key           = "${tls_private_key.ssh.private_key_pem}"
  validity_period_hours = 8760
  early_renewal_hours   = 720
  user                  = "core"
}

module "docker_client_certs" {
  source                = "github.com/Capgemini/tf_tls//docker/client"
  ca_cert_pem           = "${module.ca.ca_cert_pem}"
  ca_private_key_pem    = "${module.ca.ca_private_key_pem}"
  ip_addresses_list     = "${concat(digitalocean_droplet.master.*.ipv4_address, digitalocean_droplet.worker.*.ipv4_address)}"
  docker_client_count   = "${var.masters + var.workers}"
  private_key           = "${tls_private_key.ssh.private_key_pem}"
  validity_period_hours = 8760
  early_renewal_hours   = 720
  user                  = "core"
}
```
