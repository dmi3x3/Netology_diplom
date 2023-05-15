# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.85.0"
    }
  }
  required_version = ">= 1.3.7"



  backend "s3" {
    endpoint="storage.yandexcloud.net"
    region="ru-central1"
    access_key = "YCAJECu-CtMM0NxbOAYS6taKi"
    secret_key = "YCMMQJVO4bNSHOa4wDuFNXyJ9IzRAkmSw3MyB-Qe"
    bucket = "my-netology-bucket"
    workspace_key_prefix="tfstates"
    key="diplom_cloud.tfstate"
    skip_region_validation=true
    skip_credentials_validation=true
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
}
