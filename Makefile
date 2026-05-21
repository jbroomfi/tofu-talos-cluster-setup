SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

TFVARS_FILE ?= terraform.tfvars.json
TOFU_INIT_ARGS ?=
TOFU_PLAN_ARGS ?=
TOFU_APPLY_ARGS ?= -auto-approve
TOFU_DESTROY_ARGS ?= -auto-approve
SCRIPTS_DIR := scripts
NFS_DIR := nfs-server


.PHONY: help init plan apply destroy get-configs k8s-env cluster-up cluster-up-env cluster-down nfs-init nfs-plan nfs-apply nfs-destroy nfs-up nfs-down

help:
	@printf '%s\n' \
	  ' ' \
	  'Available targets:' \
	  '  make init            		- Run tofu init' \
	  '  make plan           		- Run tofu plan with $(TFVARS_FILE)' \
	  '  make apply           		- Run tofu apply with $(TFVARS_FILE)' \
	  '  make destroy         		- Run tofu destroy with $(TFVARS_FILE)' \
	  '  NFS-Server targets: ' \
	  '    make nfs-init        		- Run tofu init in $(NFS_DIR)' \
	  '    make nfs-plan        		- Run tofu plan in $(NFS_DIR)' \
	  '    make nfs-apply       		- Run tofu apply in $(NFS_DIR)' \
	  '    make nfs-destroy     		- Run tofu destroy in $(NFS_DIR)' \
	  '    make nfs-up          		- Provision the NFS server VM' \
	  '    make nfs-down        		- De-provision the NFS server VM' \
	  '  Cluster targets: ' \
	  '    make cluster-up      		- Provision the cluster, download configs, and print the env values' \
	  '    make cluster-down    		- De-provision the cluster with tofu destroy' \
	  '    make get-configs     		- Download talosconfig and kubeconfig into ./.kube/' \
	  '  Environment variable targets: ' \
	  '    make k8s-env         		- Print export commands for TALOSCONFIG and KUBECONFIG' \
	  '    eval "$$(make cluster-up-env)"	- Provision, download configs, and export env vars in the current shell' \
	  '    eval "$$(make k8s-env)"	- Export TALOSCONFIG and KUBECONFIG in the current shell' \
	  ' ' 

init:
	tofu init $(TOFU_INIT_ARGS)

plan:
	tofu plan $(TOFU_PLAN_ARGS) -var-file=$(TFVARS_FILE)

apply:
	tofu apply $(TOFU_APPLY_ARGS) -var-file=$(TFVARS_FILE)

destroy:
	tofu destroy $(TOFU_DESTROY_ARGS) -var-file=$(TFVARS_FILE)

nfs-init:
	tofu -chdir=$(NFS_DIR) init $(TOFU_INIT_ARGS)

nfs-plan:
	tofu -chdir=$(NFS_DIR) plan $(TOFU_PLAN_ARGS) -var-file=terraform.tfvars.json

nfs-apply:
	tofu -chdir=$(NFS_DIR) apply $(TOFU_APPLY_ARGS) -var-file=terraform.tfvars.json

nfs-destroy:
	tofu -chdir=$(NFS_DIR) destroy $(TOFU_DESTROY_ARGS) -var-file=terraform.tfvars.json

get-configs:
	./$(SCRIPTS_DIR)/get-configs.sh

k8s-env:
	@source ./$(SCRIPTS_DIR)/set-k8s-envvars.sh
	printf 'export TALOSCONFIG=%q\n' "$$TALOSCONFIG"
	printf 'export KUBECONFIG=%q\n' "$$KUBECONFIG"

cluster-up:
	@tofu init $(TOFU_INIT_ARGS)
	tofu apply $(TOFU_APPLY_ARGS) -var-file=$(TFVARS_FILE)
	./$(SCRIPTS_DIR)/get-configs.sh
	source ./$(SCRIPTS_DIR)/set-k8s-envvars.sh
	printf 'TALOSCONFIG=%s\n' "$$TALOSCONFIG"
	printf 'KUBECONFIG=%s\n' "$$KUBECONFIG"
	printf '\nUse eval "$$(make k8s-env)" to export them in your current shell.\n'

cluster-up-env:
	@exec 3>&1
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

nfs-up:
	tofu -chdir=$(NFS_DIR) init $(TOFU_INIT_ARGS)
	tofu -chdir=$(NFS_DIR) apply $(TOFU_APPLY_ARGS) -var-file=terraform.tfvars.json

nfs-down:
	tofu -chdir=$(NFS_DIR) init $(TOFU_INIT_ARGS)
	tofu -chdir=$(NFS_DIR) destroy $(TOFU_DESTROY_ARGS) -var-file=terraform.tfvars.json
