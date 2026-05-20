#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
KUBE_ROOT_DIR="$PROJECT_ROOT/.kube"

if [ ! -d "$KUBE_ROOT_DIR" ]; then
  mkdir -p "$KUBE_ROOT_DIR"
fi

tofu output -raw talos_config > "$KUBE_ROOT_DIR/talosconfig"
tofu output -raw kubeconfig > "$KUBE_ROOT_DIR/kubeconfig"
