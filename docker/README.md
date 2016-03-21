tf_docker_ca
==========
A Terraform module for creating the docker CA configuration so your docker client can connect to yor docker daemon in a secure manner on TLS

See:
https://docs.docker.com/engine/security/https/

Input Variables
---------------

Docker daemon:

`ca_cert_pem` - PEM-encoded certificate data for the CA

`ca_private_key_pem` - PEM-encoded private key data for the CA. This can be read from a separate file using the file interpolation function.

`ip_addresses_list` - List of DNS names for which a certificate is being requested.

`docker_daemon_count` - Number of machines to set up the certificates

`private_key` - ssh private key needed to ssh into the servers

`validity_period_hours` - The number of hours after initial issuing that the certificate will become invalid.

`early_renewal_hours` - https://www.terraform.io/docs/providers/tls/r/locally_signed_cert.html#early_renewal_hours

`user` - User to set the client certificates for


Usage
-----
Example setting docker client and daemon certificates for every machine in a kubernetes cluster:

```
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

Assuming you docker daemon is configured to use the certificates ```--tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server.pem --tlskey=/etc/docker/server-key.pem```, you can test it from on of the clients by running:

```
export DOCKER_HOST=tcp://$HOST:2376 DOCKER_TLS_VERIFY=1
docker ps
```

