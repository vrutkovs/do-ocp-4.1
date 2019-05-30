data "digitalocean_domain" "base" {
  name = "${var.base_domain}"
}

resource "digitalocean_domain" "cluster" {
  name = "${var.cluster_domain}"
}

resource "digitalocean_record" "api-external" {
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "api"
  value  = ["${concat(var.bootstrap_ips, var.control_plane_ips)}"]
  weight = 90
}

//TODO: Use internal IPs here
resource "digitalocean_record" "api-internal" {
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "api-int"
  value  = ["${concat(var.bootstrap_ips, var.control_plane_ips)}"]
  weight = 90
}

resource "digitalocean_record" "etcd_a_nodes" {
  count = "${var.control_plane_count}"

  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "etcd-${count.index}"
  value  = ["${element(var.control_plane_ips, count.index)}"]
}

resource "digitalocean_record" "etcd_cluster" {
  domain = "${var.cluster_domain}"
  type   = "SRV"
  ttl    = "60"
  name   = "_etcd-server-ssl._tcp"
  value  = ["${formatlist("0 10 2380 %s", digitalocean_record.etcd_a_nodes.*.fqdn)}"]
}

resource "digitalocean_record" "control_plane_nodes" {
  count = "${var.control_plane_count}"
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "control-plane-${count.index}"
  records = ["${element(var.control_plane_ips, count.index)}"]
}

resource "digitalocean_record" "compute_nodes" {
  count = "${var.compute_count}"
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "compute-${count.index}"
  records = ["${element(var.compute_ips, count.index)}"]
}
