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
  control_nodes = {
    "w-K8-control-0" = local.node
    "w-K8-control-1" = local.node
  }
  worker_nodes = {
    "w-K8-worker-0" = local.node
    "w-K8-worker-1" = local.node
    "w-K8-worker-2" = local.node
  }

  kubelet_serving_cert_approver_provider_regex = coalesce(
    var.kubelet_serving_cert_approver_provider_regex,
    "(?i)^(?:${join("|", sort(concat(keys(local.control_nodes), keys(local.worker_nodes))))})(?:\\..+)?$",
  )

  talos_installer_image = "factory.talos.dev/metal-installer/${var.talos_schematic_id}:v${var.talos_version}"
  machine_install_patch = yamlencode({
    machine = {
      install = {
        disk  = "/dev/vda"
        image = local.talos_installer_image
      }
    }
  })

  kubelet_tls_bootstrap_patch = yamlencode({
    machine = {
      kubelet = {
        extraConfig = {
          serverTLSBootstrap = true
        }
      }
    }
  })

  kubelet_serving_cert_approver_manifest = templatefile("${path.module}/inline-manifests/kubelet-csr-approver.yaml.tftpl", {
    image                 = var.kubelet_serving_cert_approver_image
    provider_regex        = local.kubelet_serving_cert_approver_provider_regex
    provider_ip_prefixes  = var.kubelet_serving_cert_approver_provider_ip_prefixes
    bypass_dns_resolution = var.kubelet_serving_cert_approver_bypass_dns_resolution
    allowed_dns_names     = var.kubelet_serving_cert_approver_allowed_dns_names
  })
  metrics_server_manifest = templatefile("${path.module}/inline-manifests/metrics-server.yaml.tftpl", {
    image                   = var.metrics_server_image
    preferred_address_types = join(",", var.metrics_server_kubelet_preferred_address_types)
  })
  cluster_inline_manifests = concat(
    var.enable_kubelet_serving_cert_approver ? [
      {
        name     = "kubelet-csr-approver"
        contents = local.kubelet_serving_cert_approver_manifest
      },
    ] : [],
    var.enable_metrics_server ? [
      {
        name     = "metrics-server"
        contents = local.metrics_server_manifest
      },
    ] : [],
  )
  cluster_inline_manifests_patch = length(local.cluster_inline_manifests) > 0 ? yamlencode({
    cluster = {
      inlineManifests = local.cluster_inline_manifests
    }
  }) : null

  disksizecontrolprimary  = var.proxmox_control_vm_primary_disk_size
  disksizeworkerprimary   = var.proxmox_worker_vm_primary_disk_size
  disksizeworkersecondary = var.proxmox_worker_vm_secondary_disk_size
  cpucores                = var.proxmox_control_vm_cores
}

module "talos" {
  source  = "bbtechsys/talos/proxmox"
  version = "0.1.6"

  talos_cluster_name = local.clustername
  talos_version      = local.talos_version
  talos_schematic_id = var.talos_schematic_id

  proxmox_worker_vm_disk_size  = local.disksizeworkerprimary
  proxmox_control_vm_disk_size = local.disksizecontrolprimary
  proxmox_worker_vm_cores      = local.cpucores
  proxmox_control_vm_cores     = local.cpucores
  control_machine_config_patches = compact([
    local.machine_install_patch,
    local.kubelet_tls_bootstrap_patch,
    local.cluster_inline_manifests_patch,
  ])
  worker_machine_config_patches = compact([
    local.machine_install_patch,
    local.kubelet_tls_bootstrap_patch,
  ])

  control_nodes = local.control_nodes

  worker_nodes = local.worker_nodes

  #

#  worker_extra_disks = {
#    "w-K8-worker-0" = [
#      {
#       datastore_id = "local-lvm"
#        size         = local.disksizeworkersecondary
#      }
#    ],
#    "w-K8-worker-1" = [
#      {
#        datastore_id = "local-lvm"
#        size         = local.disksizeworkersecondary
#      }
#    ]
#    "w-K8-worker-2" = [
#      {
#        datastore_id = "local-lvm"
#        size         = local.disksizeworkersecondary
#      }
#    ]
#  }

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