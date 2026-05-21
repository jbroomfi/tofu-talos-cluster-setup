#!/bin/bash

$PROJECT_ROOT="$(pwd)/.."
$KUBE_ROOT_DIR="$PROJECT_ROOT/.kube"
$TALOS_DIR="$PROJECT_ROOT/talos-cluster"

if (-not(Test-Path -Path $KUBE_ROOT_DIR)) {
    New-Item -ItemType Directory -Path $KUBE_ROOT_DIR
}

tofu -chdir="$TALOS_DIR" output -raw talos_config > "$KUBE_ROOT_DIR/talosconfig"
tofu -chdir="$TALOS_DIR" output -raw kubeconfig > "$KUBE_ROOT_DIR/kubeconfig"
