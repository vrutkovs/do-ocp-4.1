provider "digitalocean" {}

module "bootstrap" {
  source = "./machine"

  name           = "bootstrap"
  instance_count = "${var.bootstrap_complete ? 0 : 1}"
  ignition_url   = "${var.bootstrap_ignition_url}"
  region         = "${var.do_region}"
  image          = "${var.do_image}"
  ssh_key        = "${var.do_ssh_key}"
  size           = "s-4vcpu-8gb"
}

module "control_plane" {
  source = "./machine"

  name           = "control-plane"
  instance_count = "${var.control_plane_count}"
  ignition       = "${file("/installer/master.ign")}"
  region         = "${var.do_region}"
  image          = "${var.do_image}"
  ssh_key        = "${var.do_ssh_key}"
  size           = "s-6vcpu-16gb"
}

module "compute" {
  source = "./machine"

  name           = "compute"
  instance_count = "${var.compute_count}"
  ignition       = "${file("/installer/worker.ign")}"
  region         = "${var.do_region}"
  image          = "${var.do_image}"
  ssh_key        = "${var.do_ssh_key}"
  size           = "s-6vcpu-16gb"
}

module "dns" {
  source = "./dns"

  cluster_domain      = "${var.cluster_domain}"
  bootstrap_count     = "${var.bootstrap_complete ? 0 : 1}"
  bootstrap_ip        = "${element(module.bootstrap.ip_addresses, 0)}"
  control_plane_count = "${var.control_plane_count}"
  control_plane_ips   = ["${module.control_plane.ip_addresses}"]
  compute_count       = "${var.compute_count}"
  compute_ips         = ["${module.compute.ip_addresses}"]
}
