output "Connection Details" {
  value = "To log in to `https://${var.domain_name}` (${digitalocean_droplet.registry.ipv4_address}), use the credentials set for your users in `registry_auth` in your project directory.\n"
}

output "Cert Requirements for Docker" {
  value = "To connect using the new certificate, add the ca.crt file to /etc/docker/certs.d/${var.domain_name} and restart the Docker daemon.\n"
}
