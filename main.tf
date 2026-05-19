locals {
    cluster_name = "talos-cluster"

    pm_node = "pve-k8s"
    pm_endpoint = "https://pve-k8s.broomfieldtech.net:8006/"
    pm_tls_insecure = true

    talos_version = "1.13.2"
    talos_schematic_id = "f39a41492e6317d259e5f0d38afe198116b111d41b3bf1fdf63a528cae24eb66"
}


provider "proxmox" {
  endpoint = local.pm_endpoint
  insecure = local.pm_tls_insecure

  ssh {
    agent = true
    username = var.ssh_username
    password = var.ssh_password
  }
}