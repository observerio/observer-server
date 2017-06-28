provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_volume" "registry-data" {
    region      = "${var.region}"
    name        = "registry-data"
    size        = "${var.vol_size}"
    description = "Your Registry Data Volume"
}

resource "digitalocean_droplet" "registry" {
    image = "docker"
    name = "${var.common_name}"
    region = "${var.region}"
    size = "512mb"
    volume_ids = ["${digitalocean_volume.registry-data.id}"]
    ssh_keys = [
        "${var.ssh_fingerprint}"
    ]

    connection {
      user = "root"
      private_key = "${file(var.pvt_key)}"
    }

    provisioner "local-exec" {
      command = "chmod +x gen_keys.sh && ./gen_keys.sh ${var.user_count}"
    }

    provisioner "local-exec" {
      command = "chmod +x gen_reg_cert.sh && ./gen_reg_cert.sh \"${var.common_name}\""
    }

    provisioner "local-exec" {
      command = "chmod +x gen_htpasswd.sh && ./gen_htpasswd.sh"
    }

    provisioner "remote-exec" {
      inline = "mkdir certs && mkdir auth && mkdir /usr/local/share/ca-certificates/extra"
    }

    provisioner "file" {
      source = "certs/registry.crt"
      destination = "certs/registry.crt"
    }

    provisioner "file" {
      source = "certs/registry.key"
      destination = "certs/registry.key"
    }

    provisioner "file" {
      source = "auth/htpasswd"
      destination = "auth/htpasswd"
    }

    provisioner "remote-exec" {
      inline = [
                  "mkfs.ext3 -F /dev/sda",
                  "mkdir /registry-data && mount -t ext3 /dev/sda /registry-data && mkdir /registry-data/registry",
                  "docker run -d -p 5000:5000 --restart=always --name registry -v /registry-data/registry:/var/lib/registry -v /root/certs:/certs -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key -e \"REGISTRY_AUTH=htpasswd\" -e \"REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm\" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v /root/auth:/auth registry:2"
                ]
    }
}
