provider "digitalocean" {}

module "bootstrap" {
  source = "./machine"

  name             = "bootstrap"
  region           = "${var.do_region}"
  image            = "${var.do_image}"
  ssh_key          = "${var.do_ssh_key}"
  size             = "s-4vcpu-8gb"

  instance_count   = "${var.bootstrap_complete ? 0 : 1}"
  ignition_url     = "${var.bootstrap_ignition_url}"
}
#
# module "control_plane" {
#   source = "./machine"
#
#   name             = "control-plane"
#   instance_count   = "${var.control_plane_count}"
#   ignition         = "${var.control_plane_ignition}"
#   resource_pool_id = "${module.resource_pool.pool_id}"
#   folder           = "${module.folder.path}"
#   datastore        = "${var.vsphere_datastore}"
#   network          = "${var.vm_network}"
#   datacenter_id    = "${data.vsphere_datacenter.dc.id}"
#   template         = "${var.vm_template}"
#   cluster_domain   = "${var.cluster_domain}"
#   ipam             = "${var.ipam}"
#   ipam_token       = "${var.ipam_token}"
#   ip_addresses     = ["${var.control_plane_ips}"]
#   machine_cidr     = "${var.machine_cidr}"
# }
#
# module "compute" {
#   source = "./machine"
#
#   name             = "compute"
#   instance_count   = "${var.compute_count}"
#   ignition         = "${var.compute_ignition}"
#   resource_pool_id = "${module.resource_pool.pool_id}"
#   folder           = "${module.folder.path}"
#   datastore        = "${var.vsphere_datastore}"
#   network          = "${var.vm_network}"
#   datacenter_id    = "${data.vsphere_datacenter.dc.id}"
#   template         = "${var.vm_template}"
#   cluster_domain   = "${var.cluster_domain}"
#   ip_addresses     = ["${var.compute_ips}"]
#   machine_cidr     = "${var.machine_cidr}"
# }
#
# module "dns" {
#   source = "./dns"
#
#   base_domain         = "${var.base_domain}"
#   cluster_domain      = "${var.cluster_domain}"
#   bootstrap_count     = "${var.bootstrap_complete ? 0 : 1}"
#   bootstrap_ips       = ["${module.bootstrap.ip_addresses}"]
#   control_plane_count = "${var.control_plane_count}"
#   control_plane_ips   = ["${module.control_plane.ip_addresses}"]
#   compute_count       = "${var.compute_count}"
#   compute_ips         = ["${module.compute.ip_addresses}"]
# }
