variable "name" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "ignition" {
  type    = "string"
  default = ""
}

variable "ignition_url" {
  type    = "string"
  default = ""
}

variable "region" {
  type    = "string"
  default = ""
}

variable "image" {
  type    = "string"
  default = ""
}

variable "size" {
  type    = "string"
  default = ""
}

variable "ssh_key" {
  type    = "string"
  default = ""
}
