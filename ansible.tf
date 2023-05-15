resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

#  depends_on = [
#    local_file.inventory
#  ]
  depends_on = [
    yandex_compute_instance.cluster-k8s,
  ]
}

resource "null_resource" "k8-cluster" {
  provisioner "local-exec" {
    command = <<EOT
    ANSIBLE_FORCE_COLOR=1
    cd ../../kubespray
    ansible-playbook -i inventory/netology-diplom-cluster/${terraform.workspace}-inventory --become --become-user=root cluster.yml
    EOT
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "kubectl-config" {
  provisioner "local-exec" {
    command = <<EOF
      ssh ${var.nodes_user}@${yandex_compute_instance.cluster-k8s[0].network_interface.0.nat_ip_address} sudo sed 's/127.0.0.1:6443/${yandex_compute_instance.cluster-k8s[0].network_interface.0.nat_ip_address}:6443/g' /root/.kube/config > ~/kubectl-yc-config-dipl-${terraform.workspace}
      chmod go-rw ~/kubectl-yc-config-dipl-${terraform.workspace}
      export KUBECONFIG=~/kubectl-yc-config-dipl-${terraform.workspace}
    EOF
  }

  depends_on = [
    null_resource.k8-cluster
  ]
}

#kubectl get deploy,po,svc,ing -o wide --all-namespaces

resource "null_resource" "monitoring-setup" {
  provisioner "local-exec" {
    command = "kubectl apply --server-side -f ./kube-prometheus/manifests/setup"
  }

  depends_on = [
    null_resource.kubectl-config
  ]
}

resource "null_resource" "monitoring-wait" {
  provisioner "local-exec" {
    command = "kubectl wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring"
  }

  depends_on = [
    null_resource.monitoring-setup
  ]
}

resource "null_resource" "monitoring" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./kube-prometheus/manifests/"
  }

  depends_on = [
    null_resource.monitoring-wait
  ]
}

resource "null_resource" "jenkins-ns" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./jenkins/jenkins-namespaces.yaml"
  }
  depends_on = [
    null_resource.monitoring
  ]
}
resource "null_resource" "helm_install_app-web" {
  provisioner "local-exec" {
    command = <<EOF
      sleep 30
      helm install app-web-repo ./app_web/app-web-chart --set image_frontend.tag=latest -n stage
    EOF
  }
  depends_on = [
    null_resource.jenkins-ns
  ]
}
resource "null_resource" "install_jenkins-crd" {
  provisioner "local-exec" {
    command    = <<EOF
      sleep 30
      kubectl apply -n jenkins -f https://raw.githubusercontent.com/jenkinsci/kubernetes-operator/master/config/crd/bases/jenkins.io_jenkins.yaml
      kubectl wait --for condition=Established --all CustomResourceDefinition --namespace=jenkins
    EOF
  }
  provisioner "local-exec" {
    command    = "kubectl apply -n jenkins -f ./jenkins/all-in-one-v1alpha2.yaml"
  }
  provisioner "local-exec" {
    command    = <<EOT
      sleep 30
      kubectl create -n jenkins secret generic dockercred --from-file=.dockerconfigjson=$HOME/docker-netology/.config.json --type=kubernetes.io/dockerconfigjson
      kubectl apply -f ./jenkins/serviceaccount4stage_clusterrole.yaml
      kubectl apply -n jenkins -f ./jenkins/jenkins-instance-jen.yaml
    EOT
  }
    depends_on = [
      null_resource.helm_install_app-web
    ]
}

resource "null_resource" "login-password4jenkins" {
  provisioner "local-exec" {
    command = <<EOF
      sleep 30
      echo -e "`kubectl get -n jenkins secret jenkins-operator-credentials-j-instance -o 'jsonpath={.data.user}' | base64 -d`\n`kubectl get -n jenkins secret jenkins-operator-credentials-j-instance -o 'jsonpath={.data.password}' | base64 -d`"
    EOF
  }
    depends_on = [
      null_resource.install_jenkins-crd
    ]
}

