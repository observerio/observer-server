/*module "provider" {
  source = "./provider/scaleway"

  organization    = "${var.scaleway_organization}"
  token           = "${var.scaleway_token}"
  hosts           = "${var.hosts}"
  hostname_format = "${var.hostname_format}"
  region          = "${var.scaleway_region}"
}*/

module "provider" {
  source = "./provider/digitalocean"

  token           = "${var.digitalocean_token}"
  ssh_fingerprint = "${var.digitalocean_ssh_fingerprint}"
  hosts           = "${var.hosts}"
  hostname_format = "${var.hostname_format}"
  region          = "${var.digitalocean_region}"
  node_tag        = "${var.digitalocean_tag}"
}

/*
module "dns" {
  source = "./dns/cloudflare"

  count      = "${var.hosts}"
  email      = "${var.cloudflare_email}"
  token      = "${var.cloudflare_token}"
  domain     = "${var.domain}"
  public_ips = "${module.provider.public_ips}"
  hostnames  = "${module.provider.hostnames}"
}*/

/*
module "dns" {
  source = "./dns/google"

  count        = "${var.hosts}"
  project      = "${var.google_project}"
  region       = "${var.google_region}"
  creds_file   = "${var.google_credentials_file}"
  managed_zone = "${var.google_managed_zone}"
  domain       = "${var.domain}"
  public_ips   = "${module.provider.public_ips}"
  hostnames    = "${module.provider.hostnames}"
}
*/

module "private_docker_registry" {
  source = "./service/private_docker_registry"

  count = "${var.hosts}"
  connections = "${module.provider.public_ips}"

  domain = "${var.private_docker_registry_domain}"
}

module "swap" {
  source = "./service/swap"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
}

module "wireguard" {
  source = "./security/wireguard"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
  private_ips = "${module.provider.private_ips}"
  hostnames   = "${module.provider.hostnames}"
}

module "firewall" {
  source = "./security/ufw"

  count                = "${var.hosts}"
  connections          = "${module.provider.public_ips}"
  private_interface    = "${module.provider.private_network_interface}"
  vpn_interface        = "${module.wireguard.vpn_interface}"
  vpn_port             = "${module.wireguard.vpn_port}"
  kubernetes_interface = "${module.kubernetes.overlay_interface}"
}

module "etcd" {
  source = "./service/etcd"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
  hostnames   = "${module.provider.hostnames}"
  vpn_unit    = "${module.wireguard.vpn_unit}"
  vpn_ips     = "${module.wireguard.vpn_ips}"
}

module "kubernetes" {
  source = "./service/kubernetes"

  count          = "${var.hosts}"
  connections    = "${module.provider.public_ips}"
  cluster_name   = "${var.domain}"
  vpn_ips        = "${module.wireguard.vpn_ips}"
  etcd_endpoints = "${module.etcd.endpoints}"
}
