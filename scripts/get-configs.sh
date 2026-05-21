#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
KUBE_ROOT_DIR="$PROJECT_ROOT/.kube"
TALOS_DIR="$PROJECT_ROOT/talos-cluster"

if [ ! -d "$KUBE_ROOT_DIR" ]; then
  mkdir -p "$KUBE_ROOT_DIR"
fi

tofu -chdir="$TALOS_DIR" output -raw talos_config > "$KUBE_ROOT_DIR/talosconfig"
tofu -chdir="$TALOS_DIR" output -raw kubeconfig > "$KUBE_ROOT_DIR/kubeconfig"
