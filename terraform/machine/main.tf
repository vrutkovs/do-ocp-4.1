data "digitalocean_image" "rhcos" {
  name = "${var.image}"
}

data "digitalocean_ssh_key" "key" {
  name = "${var.ssh_key}"
}

resource "digitalocean_droplet" "vm" {
  count     = "${var.instance_count}"
  name      = "${var.name}-${count.index}"
  size      = "${var.size}"
  region    = "${var.region}"
  image     = "${data.digitalocean_image.rhcos.id}"
  user_data = "${data.template_file.ignition.*.rendered[count.index]}"
  ssh_keys  = ["${data.digitalocean_ssh_key.key.id}"]
}

output "ip_addresses" {
  value = ["${digitalocean_droplet.vm.*.ipv4_address}"]
}
