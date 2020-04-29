variable "name" {
  description = "Name of mysql instance"
}

variable "ssh_public_key" {
  description = "The path of the ssh public key that will be used"
}

variable "ssh_private_key" {
  description = "The path of the ssh private key that will be used"
}

variable "flavor_name" {
  description = "Flavor name of nodes"
}

variable "mysql_count" {
  description = "Number of mysql instances per region"
}

variable "ssh_user" {
  description = "SSH user name"
}
