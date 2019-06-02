locals {
  ignition_encoded = "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition)}"
}

data "ignition_file" "hostname" {
  count = "${var.instance_count}"

  filesystem = "root"
  path = "/etc/hostname"
  content {
    content = "${var.name}-${count.index}"
  }
  mode = "0644"
}

data "ignition_config" "ign" {
  count = "${var.instance_count}"

  append {
    source = "${var.ignition_url != "" ? var.ignition_url : local.ignition_encoded}"
  }

  files = [
    "${data.ignition_file.hostname.*.id[count.index]}"
  ]
}
