//////
// Digital Ocean variables
//////

variable "do_project" {
  type        = "string"
  description = "This is the name of the Digital Ocean project."
}

variable "do_image" {
  type        = "string"
  description = "Name of the uploaded RHCOS image."
}

variable "do_region" {
  type        = "string"
  description = "Digital Ocean region"
}

/////////
// OpenShift cluster variables
/////////

variable "cluster_id" {
  type        = "string"
  description = "This cluster id must be of max length 27 and must have only alphanumeric or hyphen characters."
}

variable "base_domain" {
  type        = "string"
  description = "The base DNS zone to add the sub zone to."
}

variable "cluster_domain" {
  type        = "string"
  description = "The base DNS zone to add the sub zone to."
}

variable "machine_cidr" {
  type = "string"
}

/////////
// Bootstrap machine variables
/////////

variable "bootstrap_complete" {
  type    = "string"
  default = "false"
}

variable "bootstrap_ignition_url" {
  type = "string"
}

variable "bootstrap_ip" {
  type    = "string"
  default = ""
}

///////////
// Control Plane machine variables
///////////

variable "control_plane_count" {
  type    = "string"
  default = "3"
}

variable "control_plane_ignition" {
  type = "string"
}

variable "control_plane_ips" {
  type    = "list"
  default = []
}

//////////
// Compute machine variables
//////////

variable "compute_count" {
  type    = "string"
  default = "3"
}

variable "compute_ignition" {
  type = "string"
}

variable "compute_ips" {
  type    = "list"
  default = []
}
