locals {
  ignition_encoded = "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition)}"
}

data "ignition_config" "ign" {
  count = "${var.instance_count}"

  append {
    source = "${var.ignition_url != "" ? var.ignition_url : local.ignition_encoded}"
  }
}
