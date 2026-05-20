SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

TFVARS_FILE ?= terraform.tfvars.json
TOFU_INIT_ARGS ?=
TOFU_PLAN_ARGS ?=
TOFU_APPLY_ARGS ?= -auto-approve
TOFU_DESTROY_ARGS ?= -auto-approve
SCRIPTS_DIR := scripts


.PHONY: help init plan apply destroy get-configs k8s-env cluster-up cluster-up-env cluster-down

help:
	printf '%s\n' \
	  'Available targets:' \
	  '  make init            - Run tofu init' \
	  '  make plan            - Run tofu plan with $(TFVARS_FILE)' \
	  '  make apply           - Run tofu apply with $(TFVARS_FILE)' \
	  '  make destroy         - Run tofu destroy with $(TFVARS_FILE)' \
	  '  make get-configs     - Download talosconfig and kubeconfig into ./.kube/' \
	  '  make k8s-env         - Print export commands for TALOSCONFIG and KUBECONFIG' \
	  '  make cluster-up      - Provision the cluster, download configs, and print the env values' \
	  '  make cluster-down    - De-provision the cluster with tofu destroy' \
	  '  eval "$$(make cluster-up-env)" - Provision, download configs, and export env vars in the current shell'

init:
	tofu init $(TOFU_INIT_ARGS)

plan:
	tofu plan $(TOFU_PLAN_ARGS) -var-file=$(TFVARS_FILE)

apply:
	tofu apply $(TOFU_APPLY_ARGS) -var-file=$(TFVARS_FILE)

destroy:
	tofu destroy $(TOFU_DESTROY_ARGS) -var-file=$(TFVARS_FILE)

get-configs:
	./$(SCRIPTS_DIR)/get-configs.sh

k8s-env:
	source ./$(SCRIPTS_DIR)/set-k8s-envvars.sh
	printf 'export TALOSCONFIG=%q\n' "$$TALOSCONFIG"
	printf 'export KUBECONFIG=%q\n' "$$KUBECONFIG"

cluster-up:
	tofu init $(TOFU_INIT_ARGS)
	tofu apply $(TOFU_APPLY_ARGS) -var-file=$(TFVARS_FILE)
	./$(SCRIPTS_DIR)/get-configs.sh
	source ./$(SCRIPTS_DIR)/set-k8s-envvars.sh
	printf 'TALOSCONFIG=%s\n' "$$TALOSCONFIG"
	printf 'KUBECONFIG=%s\n' "$$KUBECONFIG"
	printf '\nUse eval "$$(make k8s-env)" to export them in your current shell.\n'

cluster-up-env:
	exec 3>&1
	exec 1>&2
	tofu init $(TOFU_INIT_ARGS)
	tofu apply $(TOFU_APPLY_ARGS) -var-file=$(TFVARS_FILE)
	./$(SCRIPTS_DIR)/get-configs.sh
	source ./$(SCRIPTS_DIR)/set-k8s-envvars.sh
	exec 1>&3 3>&-
	printf 'export TALOSCONFIG=%q\n' "$$TALOSCONFIG"
	printf 'export KUBECONFIG=%q\n' "$$KUBECONFIG"

cluster-down:
	tofu init $(TOFU_INIT_ARGS)
	tofu destroy $(TOFU_DESTROY_ARGS) -var-file=$(TFVARS_FILE)
