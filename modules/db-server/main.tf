data "openstack_networking_network_v2" "public" {
  name = "Ext-Net"
}

resource "openstack_networking_port_v2" "public" {
  count          = var.mysql_count
  name           = "${var.name}_${count.index}"
  network_id     = data.openstack_networking_network_v2.public.id
  admin_state_up = "true"
}

data "http" "myip" {
  url = "https://api.ipify.org"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.name
  public_key = file(var.ssh_public_key)
}

data "template_file" "setup" {
  template = <<SETUP
#!/bin/bash

# install softwares & depencencies
apt update -y && apt install -y ufw python3

# setup firewall
ufw default deny
ufw allow in on ens3 proto tcp from 0.0.0.0/0 to 0.0.0.0/0 port 80
ufw allow in on ens3 proto tcp from 0.0.0.0/0 to 0.0.0.0/0 port 443
ufw allow in on ens3 proto tcp from 0.0.0.0/0 to 0.0.0.0/0 port 3306
ufw allow in on ens3 proto tcp from ${trimspace(data.http.myip.body)}/32 to 0.0.0.0/0 port 22
ufw enable

# setup systemd services
systemctl enable ufw
systemctl restart ufw
SETUP
}

data "template_file" "userdata" {
  template = <<CLOUDCONFIG
#cloud-config

write_files:
  - path: /tmp/setup/run.sh
    permissions: '0755'
    content: |
      ${indent(6, data.template_file.setup.rendered)}
  - path: /etc/systemd/network/30-ens3.network
    permissions: '0644'
    content: |
      [Match]
      Name=ens3
      [Network]
      DHCP=ipv4

runcmd:
   - /tmp/setup/run.sh
CLOUDCONFIG
}

resource "openstack_compute_instance_v2" "nodes" {
  count           = var.mysql_count
  name            = "${var.name}_${count.index}"
  image_name      = "Ubuntu 18.04"
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.keypair.name
  user_data       = data.template_file.userdata.rendered
  security_groups = ["default"]

  network {
    name = "Ext-Net"
  }
}

data "template_file" "inventory" {
  template   = "${file("${path.cwd}/ansible/templates/inventory.tpl")}"
  depends_on = [openstack_compute_instance_v2.nodes]

  vars = {
    hosts = "${join("\n", openstack_compute_instance_v2.nodes.*.access_ip_v4)}"
    user  = "${var.ssh_user}"
  }
}

resource "local_file" "inventory" {
  content  = data.template_file.inventory.rendered
  filename = "${path.cwd}/ansible/inventories/${var.name}/inventory.yml"
}

resource "null_resource" "inventory" {
  triggers = {
    template = data.template_file.inventory.rendered
  }

  provisioner "local-exec" {
    command = <<EOC
      cd ${path.cwd}/ansible && make deps && ansible-playbook -i ./inventories/${var.name}/inventory.yml \
      --private-key ${var.ssh_private_key} --vault-password-file ~/.vault \
      ./playbooks/site.yml
EOC
  }
}