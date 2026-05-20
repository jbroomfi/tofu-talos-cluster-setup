#!/bin/bash

KUBE_ROOT_DIR="$(pwd)/../.kube"

export TALOSCONFIG="$KUBE_ROOT_DIR/talosconfig"
export KUBECONFIG="$KUBE_ROOT_DIR/kubeconfig"