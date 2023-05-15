resource "local_file" "atlantis" {
  content = templatefile("atlantis-sts.tmpl",
    {
     hosts_control = "${yandex_compute_instance.cluster-k8s[0].network_interface.0.nat_ip_address}",
    }
  )
  filename = "../atlantis/${terraform.workspace}-statefulset.yaml"

  depends_on = [
    null_resource.login-password4jenkins
  ]
}


resource "null_resource" "atlantis_configmap" {
  provisioner "local-exec" {
#    command = "kubectl create configmap atlantis-files --from-file=ssh=$HOME/.ssh/id_rsa --from-file=ssh-pub=$HOME/.ssh/id_rsa.pub --from-file=key-json=key.json --from-file=server-config=server.yaml --from-file=auto-tfvars=.auto.tfvars --from-file=terraformrc=.terraformrc"
    command = "kubectl create configmap atlantis-files --from-file=key-json=key.json --from-file=server-config=server.yaml --from-file=auto-tfvars=.auto.tfvars --from-file=terraformrc=.terraformrc"
  }

  depends_on = [
    local_file.atlantis
  ]

}

resource "null_resource" "atlantis_secret" {
  provisioner "local-exec" {
    command = "kubectl create secret generic atlantis-vcs --from-literal=token=${var.personal_access_token} --from-literal=webhook-secret=${var.webhook_secret}"
  }


  depends_on = [
    null_resource.atlantis_configmap
  ]

}

resource "null_resource" "atlantis_apply" {
  provisioner "local-exec" {
    command = "kubectl apply -f ../atlantis/"
  }


  depends_on = [
    null_resource.atlantis_secret
  ]

}