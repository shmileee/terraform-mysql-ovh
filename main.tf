# Backend
terraform {
  backend "swift" {
    container = "csb-terraform"
  }
}

# Variables
variable "region" {
  default = "WAW1"
}

variable "name" {
  description = "Name of mysql instance"
}

variable "ssh_public_key" {
  description = "The path of the ssh public key that will be used"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  description = "The path of the ssh private key that will be used"
  default     = "~/.ssh/id_rsa"
}

variable "flavor_name" {
  description = "Flavor name of nodes."
  default     = "s1-2"
}

variable "mysql_count" {
  description = "Number of mysql instances per region"
  default     = 1
}

variable "ssh_user" {
  description = "SSH username"
}

# Provider
provider "openstack" {
  region = var.region
}

module "db-server" {
  source          = "./modules/db-server"
  ssh_user        = var.ssh_user
  ssh_public_key  = var.ssh_public_key
  ssh_private_key = var.ssh_private_key
  name            = var.name
  flavor_name     = var.flavor_name
  mysql_count     = var.mysql_count
  region          = var.region
}

# Outputs
output "instance_ips" {
  value = "${module.db-server.instance_ips}"
}