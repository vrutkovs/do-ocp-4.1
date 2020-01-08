locals {
  ignition_encoded = "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition)}"
}

data "template_file" "ignition" {
  count = "${var.instance_count}"

  template = "${file("/installer/ignition.json")}"
  vars = {
    ignition_url_final = "${var.ignition_url != "" ? var.ignition_url : local.ignition_encoded}"

    etc_hostname_encoded  = "${base64encode("${var.name}-${count.index}")}"
    crioconf_conf_encoded = "${base64encode(file("/installer/crio.conf"))}"
  }
}
