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

variable "proxmox_control_vm_disk_size" {
  description = "Proxmox control VM disk size in GB"
  type        = number
  default     = 16
}

variable "proxmox_worker_vm_disk_size" {
  description = "Proxmox worker VM disk size in GB"
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
  # The this id has these extensions:
  # qemu-guest-agent (required)
  # If you make your own make sure you check this extension
  # The ID is independent of the version and architecture of the image
  description = "Schematic ID for the Talos cluster"
  type        = string
  default     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
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
