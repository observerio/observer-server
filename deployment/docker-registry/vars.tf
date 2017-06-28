variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "region" {
  description = "DigitalOcean Region (Any region supporting Block Storage: nyc1,sfo2,fra1)"
  default = "nyc1"
}
variable "common_name" {
  description = "The FQDN of your registry (i.e. registry.docker.biz)"
}
variable "vol_size" {
  description = "Size of the Registry Volume"
}
variable "user_count" {
  description = "Number of users validated for this registry. (imgadm1 through this value)"
  default = "1"
}
