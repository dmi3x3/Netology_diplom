
output "internal_ip_address_nodes" {
  value = {
    for node in yandex_compute_instance.cluster-k8s:
    node.hostname => node.network_interface.0.ip_address

  }
}
output "external_ip_address_nodes" {
  value = {
    for node in yandex_compute_instance.cluster-k8s:
    node.hostname => node.network_interface.0.nat_ip_address
  }
}

output "external_load_balancer_ip" {
  value = yandex_lb_network_load_balancer.k8s-lb.listener.*.external_address_spec[0].*.address[0]
}
