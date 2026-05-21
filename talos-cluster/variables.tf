variable "proxmox_url" {
  description = "Proxmox URL"
  type        = string
  default     = "https://proxmox.internal:8006/"
}

variable "proxmox_node" {
  description = "Proxmox Node to deploy VMs on"
  type        = string
  default     = "proxmox"
}

variable "proxmox_control_vm_cores" {
  description = "Number of CPU cores for the control VMs"
  type        = number
  default     = 4
}

variable "proxmox_worker_vm_cores" {
  description = "Number of CPU cores for the worker VMs"
  type        = number
  default     = 4
}

variable "proxmox_talos_node_memory" {
  description = "Memory for each Talos node in MB"
  type        = number
  default     = 4096
}

variable "proxmox_control_vm_primary_disk_size" {
  description = "Proxmox control VM disk size in GB"
  type        = number
  default     = 16
}

variable "proxmox_worker_vm_primary_disk_size" {
  description = "Proxmox worker VM disk size in GB"
  type        = number
  default     = 16
}

variable "proxmox_worker_vm_secondary_disk_size" {
  description = "Proxmox worker VM secondary disk size in GB"
  type        = number
  default     = 32
}


variable "talos_cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
}

variable "talos_arch" {
  description = "Architecture of Talos to use"
  type        = string
  default     = "amd64"
}

variable "talos_version" {
  description = "Version of Talos to use"
  type        = string
}

variable "proxmox_iso_datastore" {
  description = "Datastore to put the qcow2 image"
  type        = string
  default     = "local"
}

variable "tls_insecure" {
  description = "Confirm insecure API access"
  type        = bool
  default     = true
}

variable "talos_schematic_id" {
  # Generate your own at https://factory.talos.dev/
  # This default schematic includes:
  # qemu-guest-agent
  # nfs-utils
  # iscsi-tools
  # util-linux-tools
  # If you make your own, keep qemu-guest-agent enabled for Proxmox guest agent support.
  # The ID is independent of the version and architecture of the image
  description = "Schematic ID for the Talos cluster"
  type        = string
  default     = "e3ffcb1daac2b1fdc51d2db5f1f34c8d644c2c86517300ef8ff8e9385a457d4f"
}

variable "worker_extra_disks" {
  # This allows for extra disks to be added to the worker VMs
  # TODO - Should we allow other things like host PCI devices as well E.g., GPUs?
  description = "Map of talos worker node name to a list of extra disk blocks for the VMs"
  type = map(list(object({
    datastore_id = string
    size         = number
    file_format  = optional(string)
    file_id      = optional(string)
  })))
  default = {}
}
