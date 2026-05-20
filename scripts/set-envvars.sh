#!/bin/bash

KUBE_ROOT_DIR="$(pwd)/../.kube"

# export PROXMOX_VE_USERNAME="root@pam"
# export PROXMOX_VE_PASSWORD="?SysMin22?"

# 
export PROXMOX_VE_USERNAME="terraform@pam"
export PROXMOX_VE_PASSWORD="?Pa55W0rd1?"

export TALOSCONFIG="$KUBE_ROOT_DIR/talosconfig"
export KUBECONFIG="$KUBE_ROOT_DIR/kubeconfig"