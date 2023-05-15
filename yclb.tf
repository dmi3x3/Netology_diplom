resource "yandex_lb_target_group" "k8s_lb_tg" {
  name = "${terraform.workspace}-k8s-tg"

  dynamic "target" {
    for_each = [for node in yandex_compute_instance.cluster-k8s: {
      address   = node.network_interface.0.ip_address
      subnet_id = node.network_interface.0.subnet_id
    }]

    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }

  depends_on = [
    yandex_compute_instance.cluster-k8s 
  ]

}

resource "yandex_lb_network_load_balancer" "k8s-lb" {
  name = "${terraform.workspace}-k8s-lb"

  listener {
    name        = "grafana-listener"
    port        = 3000
    target_port = 30030
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  listener {
    name        = "j-instance-listener"
    port        = 8080
    target_port = 30808
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  listener {
    name        = "app-listener"
    port        = 80
    target_port = 30080
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_lb_tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 30030
        path = "/login"
      }
    }
  }
}
