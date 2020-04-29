terraform {
  backend "swift" {
    container = "csb-terraform"
  }
}

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
}