#!/bin/bash

$KUBE_ROOT_DIR="$(pwd)/../.kube"

if (-not(Test-Path -Path $KUBE_ROOT_DIR)) {
    New-Item -ItemType Directory -Path $KUBE_ROOT_DIR
}

tofu output -raw talos_config > "$KUBE_ROOT_DIR/talosconfig"
tofu output -raw kubeconfig > "$KUBE_ROOT_DIR/kubeconfig"