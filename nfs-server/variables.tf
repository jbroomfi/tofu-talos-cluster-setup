variable "proxmox_url" {
  description = "Proxmox URL"
  type        = string
  default     = "https://proxmox.internal:8006/"
}

variable "proxmox_fqdn" {
  description = "Proxmox FQDN for node"
  type        = string
  default     = "proxmox.internal"
}

variable "proxmox_admin_user" {
  description = "Proxmox admin username"
  type        = string
  default     = "root@pam"
}

variable "proxmox_admin_password" {
  description = "Proxmox admin password"
  type        = string
  default     = "<password>"
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
