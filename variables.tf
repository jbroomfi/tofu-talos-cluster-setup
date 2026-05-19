variable "ssh_username" {
    description = "SSH username for Proxmox API access"
    type        = string
}

variable "ssh_password" {
    description = "SSH password for Proxmox API access"
    type        = string
    sensitive   = true
}