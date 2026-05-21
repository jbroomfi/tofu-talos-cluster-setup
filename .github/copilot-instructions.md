# Copilot instructions for this repository

## Build, test, and lint commands

This repository is an OpenTofu infrastructure project. There is no application build step and no automated test suite or `*.tftest.hcl` test files at the moment.

Use these OpenTofu commands from the repository root for the Talos cluster configuration in `./talos-cluster`:

| Command | Purpose |
| --- | --- |
| `tofu -chdir=talos-cluster init` | Install providers and the external Talos module if `talos-cluster/.terraform/` is missing or stale. |
| `tofu fmt -check -recursive` | Formatting check; this is the closest thing to a lint step in this repo. |
| `tofu -chdir=talos-cluster validate` | Validate the configuration. It currently succeeds with a deprecation warning coming from the upstream `bbtechsys/talos/proxmox` module. |
| `tofu -chdir=talos-cluster plan -var-file=terraform.tfvars.json` | Review the infrastructure changes for the configured cluster. |
| `tofu -chdir=talos-cluster apply -var-file=terraform.tfvars.json` | Apply the cluster changes to Proxmox. |
| `cd scripts && ./get-configs.sh` | Write `talosconfig` and `kubeconfig` into the repository `.kube/` directory after apply. |
| `cd scripts && source ./set-k8s-envvars.sh` | Export `TALOSCONFIG` and `KUBECONFIG` pointing at the generated files in the repository `.kube/` directory. |

Single-test command: not applicable yet, because this repository does not define an automated test suite.

## High-level architecture

The Talos configuration in `talos-cluster/` is intentionally thin and delegates almost all provisioning to the external module `bbtechsys/talos/proxmox`.

- `talos-cluster/terraform.tf` pins provider sources and minimum versions for `bpg/proxmox`, `siderolabs/talos`, and `hashicorp/time`.
- `talos-cluster/main.tf` configures the Proxmox provider, defines local defaults, instantiates the Talos-on-Proxmox module, and exposes `talos_config` plus `kubeconfig` as sensitive outputs.
- `talos-cluster/variables.tf` holds operator-supplied inputs such as cluster name, Talos version, Proxmox endpoint, schematic ID, and a few defaults.
- `talos-cluster/terraform.tfvars.json.example` shows the expected input format; the repo uses JSON tfvars rather than HCL tfvars.
- `scripts/` handles post-provision workflow: extracting the generated configs and exporting `TALOSCONFIG` / `KUBECONFIG`.
- `docs/pre-requisites/` documents the external setup that Terraform/OpenTofu expects to already exist, especially the Proxmox user, SSH access, and required environment variables.

## Key conventions

- Cluster topology is hardcoded in `talos-cluster/main.tf`, not derived from `terraform.tfvars.json`. If you need to change the number of control or worker nodes, their names, MAC addresses, or the extra worker disks, edit `module "talos"` inputs in `talos-cluster/main.tf`.
- The current topology is two control-plane VMs and three worker VMs, all scheduled onto the single Proxmox node referenced by `var.proxmox_node`.
- Resource sizing is split across files: some defaults exist in `talos-cluster/variables.tf`, but the values actually passed into the module are set through `locals` in `talos-cluster/main.tf`. When changing CPU or disk behavior, check both files before assuming a variable is wired through.
- Proxmox credentials are expected through environment variables (`PROXMOX_VE_USERNAME` and `PROXMOX_VE_PASSWORD`) as described in `docs/pre-requisites/environment-variables.md`; they are not meant to live in committed tfvars files.
- Generated artifacts are intentionally untracked. `.gitignore` excludes `.kube/`, tfvars files, state files, and SSH key material, so avoid moving generated configs into tracked paths.
- The shell scripts resolve the repository root from the script location and then read outputs from `talos-cluster/`, so keep that directory layout intact if you automate around them.
- Prefer the Bash scripts as the source of truth for automation. The checked-in PowerShell scripts currently contain Bash-style variable assignment patterns and should be reviewed before relying on them unchanged.
