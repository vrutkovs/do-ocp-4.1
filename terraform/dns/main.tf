resource "digitalocean_domain" "cluster" {
  name = "${var.cluster_domain}"
}

resource "digitalocean_record" "api-external-bootstrap" {
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "api"
  value  = "${element(var.bootstrap_ips, count.index)}"
  weight = 90
  count  = "${var.bootstrap_count}"
}

resource "digitalocean_record" "api-external" {
  count = "${var.control_plane_count}"
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "api"
  weight = 90
  value  = "${element(var.control_plane_ips, count.index)}"
}

//TODO: Use internal IPs here
resource "digitalocean_record" "api-internal-bootstrap" {
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "api-int"
  value  = "${element(var.bootstrap_ips, count.index)}"
  weight = 90
  count  = "${var.bootstrap_count}"
}

resource "digitalocean_record" "api-internal" {
  count = "${var.control_plane_count}"
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "api-int"
  value  = "${element(var.control_plane_ips, count.index)}"
  weight = 90
}

resource "digitalocean_record" "etcd_a_nodes" {
  count = "${var.control_plane_count}"

  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "etcd-${count.index}"
  value  = "${element(var.control_plane_ips, count.index)}"
}

resource "digitalocean_record" "etcd_cluster" {
  count    = "${var.control_plane_count}"
  domain   = "${var.cluster_domain}"
  type     = "SRV"
  ttl      = "60"
  name     = "_etcd-server-ssl._tcp"
  value    = "${element(split(".", element(digitalocean_record.etcd_a_nodes.*.fqdn, count.index)),0)}"
  priority = "0"
  weight   = "10"
  port     = "2380"
}

resource "digitalocean_record" "control_plane_nodes" {
  count  = "${var.control_plane_count}"
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "control-plane-${count.index}"
  value  = "${element(var.control_plane_ips, count.index)}"
}

resource "digitalocean_record" "compute_nodes" {
  count  = "${var.compute_count}"
  domain = "${var.cluster_domain}"
  type   = "A"
  ttl    = "60"
  name   = "compute-${count.index}"
  value  = "${element(var.compute_ips, count.index)}"
}
