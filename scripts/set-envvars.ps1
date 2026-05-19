$KUBE_ROOT_DIR="$(pwd)/../.kube"

Set-Item ENV:PROXMOX_VE_USERNAME -value "root@pam"
Set-Item ENV:PROXMOX_VE_PASSWORD -value "?SysMin22?"

Set-Item ENV:TALOSCONFIG -value "$KUBE_ROOT_DIR/talosconfig"
Set-Item ENV:KUBECONFIG -value "$KUBE_ROOT_DIR/kubeconfig"