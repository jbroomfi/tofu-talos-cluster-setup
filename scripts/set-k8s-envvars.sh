#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
KUBE_ROOT_DIR="$PROJECT_ROOT/.kube"

export TALOSCONFIG="$KUBE_ROOT_DIR/talosconfig"
export KUBECONFIG="$KUBE_ROOT_DIR/kubeconfig"
