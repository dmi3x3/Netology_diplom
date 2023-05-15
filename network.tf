# Network

resource "yandex_vpc_network" "netology-diplom" {
  name = "${terraform.workspace}-netology-diplom"
}

resource "yandex_vpc_subnet" "subnet-zones" {
  count          = 3
  name           = "${terraform.workspace}-subnet-${var.subnet-zones[count.index]}"
  zone           = "${var.subnet-zones[count.index]}"
  network_id     = "${yandex_vpc_network.netology-diplom.id}"
  v4_cidr_blocks = [ "${var.cidr[terraform.workspace][count.index]}" ]
}

#resource "yandex_vpc_address" "addr1-a" {
#  name = "static-ip1-a"
#  external_ipv4_address {
#    zone_id = "ru-central1-a"
#  }
#}
