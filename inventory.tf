 resource "local_file" "inventory" {
  content = templatefile("inventory.tmpl",
    {
     all_nodes = yandex_compute_instance.cluster-k8s,
     nodes_user = var.nodes_user,
    }
  )
  filename = "../../kubespray/inventory/netology-diplom-cluster/${terraform.workspace}-inventory"
}

