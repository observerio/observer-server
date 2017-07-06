variable "count" {}

variable "domain" {}

variable "connections" {
  type = "list"
}

resource "null_resource" "certificates" {
  count = "${var.count}"

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/docker/certs.d/${var.domain}/"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/../../../docker-registry/certs/ca.crt"
    destination = "/etc/docker/certs.d/${var.domain}/ca.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart docker",
    ]
  }
}
