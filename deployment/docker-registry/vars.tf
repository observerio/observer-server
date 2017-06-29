variable "do_token" {
  default = ""
}
variable "pub_key" {
  default = ""
}
variable "pvt_key" {
  default = ""
}
variable "ssh_fingerprint" {
  default = ""
}
variable "region" {
  description = "DigitalOcean Region (Any region supporting Block Storage: nyc1,sfo2,fra1)"
  default = "nyc1"
}
variable "common_name" {
  description = "The FQDN of your registry (i.e. registry.docker.biz)"
  default = ""
}
variable "vol_size" {
  description = "Size of the Registry Volume"
  default = "1Gb"
}
variable "user_count" {
  description = "Number of users validated for this registry. (imgadm1 through this value)"
  default = "1"
}
