#!/bin/bash

tofu output -raw talos_config > ./.kube/talosconfig
tofu output -raw kubeconfig > ./.kube/kubeconfig