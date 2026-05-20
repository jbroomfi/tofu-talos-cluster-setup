#!/bin/bash

KUBE_ROOT_DIR="$(pwd)/../.kube"

<<<<<<< HEAD:scripts/set-envvars.sh
# export PROXMOX_VE_USERNAME="root@pam"
# export PROXMOX_VE_PASSWORD="?SysMin22?"

# 
export PROXMOX_VE_USERNAME="terraform@pam"
export PROXMOX_VE_PASSWORD="?Pa55W0rd1?"

=======
>>>>>>> 1378b6959a30f29a842ffe0c01b3bf27d02c90b5:scripts/set-k8s-envvars.sh
export TALOSCONFIG="$KUBE_ROOT_DIR/talosconfig"
export KUBECONFIG="$KUBE_ROOT_DIR/kubeconfig"