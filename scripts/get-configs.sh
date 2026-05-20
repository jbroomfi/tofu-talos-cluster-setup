#!/bin/bash

KUBE_ROOT_DIR="$(pwd)/../.kube"

if [ ! -d "$KUBE_ROOT_DIR" ]; then
  mkdir -p "$KUBE_ROOT_DIR"
fi

tofu output -raw talos_config > "$KUBE_ROOT_DIR/talosconfig"
tofu output -raw kubeconfig > "$KUBE_ROOT_DIR/kubeconfig"
