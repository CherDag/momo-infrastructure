terraform {
 required_providers {
  yandex = {
  source  = "yandex-cloud/yandex"
  version = "0.82.0"
  }
 }
}

# 1. Кластер
resource "yandex_kubernetes_cluster" "k8s-cluster01" {
  name        = "k8s-cluster01" 
  description = "Terraform installed cluser"
  network_id = yandex_vpc_network.k8net.id

  service_account_id      = yandex_iam_service_account.asch-k8s-sa.id
  node_service_account_id = yandex_iam_service_account.asch-k8s-sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]

  release_channel = "STABLE"
  
  master {
    zonal {
        zone = yandex_vpc_subnet.k8subnet.zone
        subnet_id = yandex_vpc_subnet.k8subnet.id
    }

    version = "1.22"
    public_ip = true

  }
}

resource "yandex_kubernetes_node_group" "k8s-node-group01" {

    name        = "k8s-node-group01"
    description = "Terraform node group"
    version = "1.22"
    cluster_id = "${yandex_kubernetes_cluster.k8s-cluster01.id}"

    instance_template {

      platform_id="standard-v1"

      network_interface {
        nat = true
        subnet_ids = [ "${yandex_vpc_subnet.k8subnet.id}" ]
      }

      resources {
        memory = 8
        cores = 2
        core_fraction = 20
      }

      boot_disk {
        type = "network-hdd"
        size = 64
      }

      container_runtime {
        type = "docker"
      }

    }

    scale_policy {
      fixed_scale {
        size = 1
      }
    }

    allocation_policy {
      location {
        zone = var.yc_zone_name
      }
    }

    deploy_policy {
      max_expansion = 1
      max_unavailable = 1
    }
  
}

resource "yandex_vpc_network" "k8net" {
  name = "k8net"
}

resource "yandex_vpc_subnet" "k8subnet" {
  name = "k8subnet"
  v4_cidr_blocks = [ "10.10.0.0/24" ]
  zone = var.yc_zone_name
  network_id = yandex_vpc_network.k8net.id
}

resource "yandex_iam_service_account" "asch-k8s-sa" {
  name = "asch-k8s-sa"
  description = "Kubernetes Service account. Terraform created"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yc_folder_id
  role = "editor"
  members = [ "serviceAccount:${yandex_iam_service_account.asch-k8s-sa.id}" ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.yc_folder_id
  role = "container-registry.images.puller"
  members = [ "serviceAccount:${yandex_iam_service_account.asch-k8s-sa.id}" ]
}