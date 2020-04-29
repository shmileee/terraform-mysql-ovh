output "instance_ips" {
  value = openstack_compute_instance_v2.nodes.*.access_ip_v4
}