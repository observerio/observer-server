/* general */
variable "hosts" {
  default = 3
}

variable "domain" {
  default = "observer.rubyforce.co"
}

variable "hostname_format" {
  default = "kube%d"
}

/* scaleway */
variable "scaleway_organization" {
  default = ""
}

variable "scaleway_token" {
  default = ""
}

variable "scaleway_region" {
  default = "ams1"
}

/* digitalocean */
variable "digitalocean_token" {
  default = ""
}

variable "digitalocean_ssh_fingerprint" {
  default = ""
}

variable "digitalocean_region" {
  default = "nyc1"
}

variable "digitalocean_tag" {
  default = "k8s-node"
}

/* cloudflare */
variable "cloudflare_email" {
  default = ""
}

variable "cloudflare_token" {
  default = ""
}

/* google dns */
variable "google_project" {
  default = ""
}

variable "google_region" {
  default = ""
}

variable "google_managed_zone" {
  default = ""
}

variable "google_credentials_file" {
  default = ""
}

variable "private_docker_registry_domain" {
  default = ""
}
