# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1ga4odn0i44r8qgorf8"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gc33n2kn0qsjgcmia2"
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list

variable "ubuntu-2004-lts" {
  default = "fd8nn6vae2u4vo18bv3s"
}

variable "nodes_user" {
  default = "ndiplom"
}

variable "subnet-zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}

variable "cidr" {
  type    = map(list(string))
  default = {
    stage = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
    prod  = ["10.10.11.0/24", "10.10.22.0/24", "10.10.33.0/24"]
  }
}

variable "cp_count" {
  default = "1"
  description = "How many control plains"
  }

variable "nodes_count" {
  default = "2"
  description = "How many nodes"
  }

variable "personal_access_token" {
  type    = string
  default = null
}

variable "webhook_secret" {
  default = "diplomnetologysecret"
}

variable "gh_token" {
  type    = string
  default = null
}

variable "rev_request" {
  type = string
  default = 1
}
