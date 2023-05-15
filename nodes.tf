resource "yandex_compute_instance" "cluster-k8s" {
  count   = 3
  name                      = "${terraform.workspace}-node-${count.index}"
  zone                      = "${var.subnet-zones[count.index]}"
  hostname                  = "${terraform.workspace}-node-${count.index}"
  allow_stopping_for_update = true
  labels = {
    index = "${count.index}"
  } 
 
  scheduling_policy {
  preemptible = true  // Прерываемая ВМ
  }

platform_id = "standard-v3"

  resources {
    cores  = 4
    memory = 12
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu-2004-lts}"
      type        = "network-ssd"
      size        = "20"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.subnet-zones[count.index].id}"
    nat        = true
  }

    

#  metadata = {
#    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
#  }
  metadata = {
    user-data = "${file("./meta.inf")}"
  }
}
