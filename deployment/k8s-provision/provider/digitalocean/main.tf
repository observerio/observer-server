variable "token" {}

variable "hosts" {
  default = 0
}

variable "ssh_fingerprint" {}
variable "ssh_private_key" {
    default = "~/.ssh/id_rsa"
}

variable "hostname_format" {
  type = "string"
}

variable "region" {
  type    = "string"
  default = "fra1"
}

variable "image" {
  type    = "string"
  default = "ubuntu-16-04-x64"
}

variable "size" {
  type    = "string"
  default = "1gb"
}

variable "node_tag" {
  type = "string"
}

provider "digitalocean" {
  token = "${var.token}"
}

resource "digitalocean_tag" "node_tag" {
  name = "${var.node_tag}"
}

resource "digitalocean_droplet" "host" {
  name               = "${format(var.hostname_format, count.index + 1)}"
  region             = "${var.region}"
  image              = "${var.image}"
  size               = "${var.size}"
  backups            = false
  private_networking = true
  ssh_keys           = ["${split(",", var.ssh_fingerprint)}"]
  tags               = ["${var.node_tag}"]

  count = "${var.hosts}"

  provisioner "remote-exec" {
    inline = [
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",
      "apt-get update",
      "apt-get install -yq nfs-common",
    ]
  }
}

resource "digitalocean_loadbalancer" "public" {
  name = "${format(var.hostname_format, 0)}-loadbalancer"
  region = "${var.region}"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = ["${digitalocean_droplet.host.*.id}"]

  droplet_tag = "${var.node_tag}"
}

output "hostnames" {
  value = ["${digitalocean_droplet.host.*.name}"]
}

output "public_ips" {
  value = ["${digitalocean_droplet.host.*.ipv4_address}"]
}

output "private_ips" {
  value = ["${digitalocean_droplet.host.*.ipv4_address_private}"]
}

output "private_network_interface" {
  value = "eth1"
}
