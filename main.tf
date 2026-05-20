provider "proxmox" {
  endpoint = var.proxmox_url
  insecure = var.tls_insecure

  # ssh {
  #    agent    = true
  #    username = var.ssh_username
  #    password = var.ssh_password
  # }
}

locals {

  node          = var.proxmox_node
  clustername   = var.talos_cluster_name
  talos_version = var.talos_version

  disksizecontrolprimary  = 16
  disksizeworkerprimary   = 16
  disksizeworkersecondary = 32
  cpucores                = 2
}

module "talos" {
  source  = "bbtechsys/talos/proxmox"
  version = "0.1.6"

  talos_cluster_name = local.clustername
  talos_version      = local.talos_version

  proxmox_worker_vm_disk_size  = local.disksizeworkerprimary
  proxmox_control_vm_disk_size = local.disksizecontrolprimary
  proxmox_worker_vm_cores      = local.cpucores
  proxmox_control_vm_cores     = local.cpucores

  control_nodes = {
    "w-K8-control-0" = local.node
    "w-K8-control-1" = local.node
  }

  worker_nodes = {
    "w-K8-worker-0" = local.node
    "w-K8-worker-1" = local.node
    "w-K8-worker-2" = local.node
  }

  #

  worker_extra_disks = {
    "w-K8-worker-0" = [
      {
        datastore_id = "local-lvm"
        size         = local.disksizeworkersecondary
      }
    ],
    "w-K8-worker-1" = [
      {
        datastore_id = "local-lvm"
        size         = local.disksizeworkersecondary
      }
    ]
    "w-K8-worker-2" = [
      {
        datastore_id = "local-lvm"
        size         = local.disksizeworkersecondary
      }
    ]
  }

  control_plane_mac_addresses = {
    "w-K8-control-0" = "bc:24:11:d4:d6:37"
    "w-K8-control-1" = "bc:24:11:5d:f3:9b"
  }

  worker_mac_addresses = {
    "w-K8-worker-0" = "bc:24:11:cd:18:27"
    "w-K8-worker-1" = "bc:24:11:01:08:e0"
    "w-K8-worker-2" = "bc:24:11:cd:fe:19"
  }

}

output "talos_config" {
  description = "Talos configuration file"
  value       = module.talos.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig file"
  value       = module.talos.kubeconfig
  sensitive   = true
}