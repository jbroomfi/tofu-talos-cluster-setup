terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.106.0"
    }
  }
}

#provider "proxmox" {
#  endpoint  = "https://proxmox.internal:8006/api2/json"
#  api_token = "root@pam!terraform=YOUR_TOKEN"
#  insecure  = true
#}

locals {
  node     = var.proxmox_node
  username = var.proxmox_admin_user
  user     = "root"
  password = var.proxmox_admin_password
}

provider "proxmox" {
  endpoint = var.proxmox_url
  # api_token = "root@pam!tofu=fce117e6-455e-48cf-8ba9-78674d5c18bf"
  username = local.username
  password = local.password
  insecure = true
}




############################
# One-time Proxmox host setup
############################
resource "null_resource" "proxmox_prep" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/vz/snippets",
      "chmod 755 /var/lib/vz/snippets",
      "grep -q snippets /etc/pve/storage.cfg || sed -i 's/content.*/&,snippets/' /etc/pve/storage.cfg"
    ]

    connection {
      type     = "ssh"
      user     = local.user
      host     = var.proxmox_fqdn
      password = local.password
      # or use:
      # private_key = file("~/.ssh/id_rsa")
    }
  }
}


############################
# Download Debian cloud image
############################
resource "proxmox_download_file" "debian" {
  content_type = "import"
  datastore_id = "local"
  node_name    = local.node

  url       = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  file_name = "debian-12.qcow2"
}

############################
# Cloud-init config (NFS setup)
############################

resource "proxmox_virtual_environment_file" "cloudinit" {
  depends_on = [null_resource.proxmox_prep]

  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.node

  source_raw {
    data = <<EOF
#cloud-config
users:
  - name: nfs-admin
    lock_passwd: false
    passwd: "?TestPassword2026?"
    primary_group: nfs-admin
    groups: users, sudo
    shell: /bin/bash

hostname: nfs-server

package_update: true

packages:
  - nfs-kernel-server

runcmd:
  - mkdir -p /srv/nfs
  - echo "/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
  - systemctl enable nfs-server --now
  - systemctl restart network.service
EOF

    file_name = "nfs.yaml"
  }
}


############################
# VM
############################
resource "proxmox_virtual_environment_vm" "nfs_vm" {
  name      = "nfs-server"
  node_name = local.node
  vm_id     = 300

  cpu {
    type  = "x86-64-v2-AES"
    cores = 2
  }

  memory {
    dedicated = 1024
  }

  # Main disk (100GB)
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"

    file_id = proxmox_download_file.debian.id
    size    = 100
  }

  # Cloud-init
  initialization {
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloudinit.id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  # Networking
  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "bc:24:11:6e:a0:01"
  }

  # Required for cloud images
  serial_device {}

  vga {
    type = "serial0"
  }

  boot_order = ["virtio0"]

  started = true
}
