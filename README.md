# Tofu Talos Cluster Setup

This repository manages two Proxmox workloads with OpenTofu:

1. A Talos Kubernetes cluster in `./talos-cluster`
2. An optional NFS server VM in `./nfs-server`

The repository root is now primarily an orchestration layer. The root `Makefile` is the recommended entrypoint for day-to-day use, while the actual OpenTofu configurations live in their own subdirectories.

## Repository structure

| Path | Purpose |
| --- | --- |
| `talos-cluster/` | Talos cluster OpenTofu configuration, state, and tfvars |
| `nfs-server/` | NFS server OpenTofu configuration, state, and tfvars |
| `scripts/get-configs.sh` | Reads Talos outputs from `talos-cluster/` and writes `./.kube/talosconfig` and `./.kube/kubeconfig` |
| `scripts/set-k8s-envvars.sh` | Exports `TALOSCONFIG` and `KUBECONFIG` pointing at `./.kube/` |
| `docs/pre-requisites/` | Proxmox user, environment variable, and setup documentation |
| `Makefile` | Root convenience wrapper for the Talos and NFS workflows |

## Pre-requisites

Before provisioning anything, complete:

1. [Add a terraform linux user account](./docs/pre-requisites/add-linux-user-account.md)
2. [Required environment variables](./docs/pre-requisites/environment-variables.md)

At minimum, the OpenTofu runs in this repository expect:

- `PROXMOX_VE_USERNAME`
- `PROXMOX_VE_PASSWORD`

## Configure inputs

Create the local tfvars files from the checked-in examples.

### Talos cluster

```bash
cp talos-cluster/terraform.tfvars.json.example talos-cluster/terraform.tfvars.json
```

Edit `talos-cluster/terraform.tfvars.json` for your environment.

By default, `talos-cluster/variables.tf` points at a Talos Factory schematic that includes:

- `qemu-guest-agent`
- `nfs-utils`
- `iscsi-tools`
- `util-linux-tools`

If you generate your own schematic, set `talos_schematic_id` in `talos-cluster/terraform.tfvars.json`.
The Talos config now uses that schematic both for the initial Proxmox image download and for the Talos installer image recorded in machine configuration, so future extension changes stay in OpenTofu-managed config.

This Talos config enables kubelet `serverTLSBootstrap` and deploys a `kubelet-csr-approver` inline manifest from the control plane machine config. Talos manages kubelet client certificate rotation itself, so this repo does not override `rotateCertificates`. For a stricter approver policy, set `kubelet_serving_cert_approver_provider_ip_prefixes` in `talos-cluster/terraform.tfvars.json` to the CIDR range(s) used by your Talos nodes.

### NFS server

```bash
cp nfs-server/terraform.tfvars.json.example nfs-server/terraform.tfvars.json
```

Edit `nfs-server/terraform.tfvars.json` for your environment.

## Talos cluster workflow

All Talos targets are invoked from the repository root, but they execute OpenTofu commands inside `./talos-cluster`.

### Plan and provision

```bash
make plan
make cluster-up
```

`make cluster-up` runs:

1. `tofu -chdir=talos-cluster init`
2. `tofu -chdir=talos-cluster apply -var-file=terraform.tfvars.json`
3. `./scripts/get-configs.sh`
4. `./scripts/set-k8s-envvars.sh`
5. Prints the resolved `TALOSCONFIG` and `KUBECONFIG` paths

If you want provisioning plus shell exports in a single command, use:

```bash
eval "$(make cluster-up-env)"
```

### Refresh local access files

If the cluster already exists and you only need fresh local configs:

```bash
make get-configs
eval "$(make k8s-env)"
```

This refreshes:

- `./.kube/talosconfig`
- `./.kube/kubeconfig`

### Tear down the cluster

```bash
make cluster-down
```

## NFS server workflow

The NFS server uses its own OpenTofu configuration in `./nfs-server`. The root `Makefile` wraps the common lifecycle commands.

### Plan and provision

```bash
make nfs-plan
make nfs-up
```

`make nfs-up` runs `tofu init` and `tofu apply` inside `./nfs-server`.

### Destroy

```bash
make nfs-down
```

### Lower-level NFS targets

```bash
make nfs-init
make nfs-plan
make nfs-apply
make nfs-destroy
```

## Available Make targets

### Talos cluster targets

```bash
make init
make plan
make apply
make destroy
make cluster-up
make cluster-up-env
make cluster-down
make get-configs
make k8s-env
```

These all operate on `./talos-cluster`.

### NFS server targets

```bash
make nfs-init
make nfs-plan
make nfs-apply
make nfs-destroy
make nfs-up
make nfs-down
```

These all operate on `./nfs-server`.

## Notes

- Cluster topology is hardcoded in `talos-cluster/main.tf`, not derived from `terraform.tfvars.json`
- The root `Makefile` is the intended interface; you usually do not need to `cd` into either OpenTofu directory manually
- Generated artifacts such as `./.kube/`, local tfvars files, and state files are intentionally untracked
- Running `make` with no arguments prints the current help text
- On an existing cluster, changing `talos_schematic_id` updates the desired installer image, but you still need a rolling `talosctl upgrade` to replace the running Talos image on each node
- Kubelet serving certificate approval is now managed from `talos-cluster/main.tf` using a Talos inline manifest; if node hostnames are not resolvable in DNS, set `kubelet_serving_cert_approver_bypass_dns_resolution=true` or supply resolvable node DNS names
