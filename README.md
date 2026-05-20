# Tofu-Talos-Cluster-Setup

## Background

This project details the pre-requisites and steps required to deploy a talos linux Kubernetes cluster on a Proxmox Virtual Environment.  It uses the open-source version of Terraform, a product called OpenTofu, to provision the VM's on the Proxmox server.  

The configuration of each VM is declared in a .tf file and tofu will generate an execution plan against the Proxmox environment that when applied will create the VMs with the exact specs listed in the tf file.  This approach ensures a level of consistency between different environments (assuming no changes are made to the TF files before executing the scripts).

## References
  * [OpenTofu (v1.12.0)](https://opentofu.org)
  * [Proxmox Virtual Environment (v9.1.14)](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview)
  * [Terraform Providers](https://search.opentofu.org)
    -  [bpg/proxmox (v0.106.0)](https://search.opentofu.org/provider/bpg/proxmox/latest)
    -  [siderolabs/talos (v0.11.0)](https://search.opentofu.org/provider/siderolabs/talos/latest)
    -  [hashicorp/time (v0.14.0)](https://search.opentofu.org/provider/hashicorp/time/latest)

**Note** Versions listed above were the latest versions available at the time this document was created or last modified.  

Alpha and Beta versions should not be considered as candidates for use in this solution unless the alpha/beta release fixes a specific issue being experienced.

### Assumptions

* You have a proxmox virtual server environment available with sufficient free resources available for the Talos Node VMs
* That you have experience with Proxmox VE, OpenTofu and Talos Linux
* You're comfortable with or willing to learn about using the linux command line
* Where possible PowerShell scripts will be provided but if scripts are required they will be written in bash first and then PowerShell

Note: Each Talos Node that you configure will require at a minimum 4GB of RAM and two virtual storage drives (one for boot/system and another larger drive for a replicated ceph storage config)
```mermaid
block-beta
columns 1
  block:ControlPlane
    Node1["CP1<br/><a style='font-size: 8pt'>4GB<br/>/dev/sda<br/>/dev/sdb"]
    Node2["CP2<br/><a style='font-size: 8pt'>4GB<br/>/dev/sda<br/>/dev/sdb"]
    Node3["CP3<br/><a style='font-size: 8pt'>4GB<br/>/dev/sda<br/>/dev/sdb"]
  end
  space
  block:WorkerPlane
    WorkerNode1["WN1<br/><a style='font-size: 8pt'>4GB<br/>/dev/sda<br/>/dev/sdb"]
    WorkerNode2["WN2<br/><a style='font-size: 8pt'>4GB<br/>/dev/sda<br/>/dev/sdb"]
  end
  ControlPlane --> WorkerPlane
  WorkerPlane --> ControlPlane
  
```
## Pre-requisites

1. [Add a terraform linux user account](./docs/pre-requisites/add-linux-user-account.md)
2. [Environment Variables](./docs/pre-requisites//environment-variables.md)

## Preparing Tofu Resources

* make sure to set the environment variables for
  * Proxmox VE
  * Terraform (PM_USER/PASS, PM_API_TOKEN_ID, PM_API_TOKEN_SECRET, PROXMOX_VE_API_TOKEN, PM_API_URL, PM_TLS_INSECURE)


## Verifying the plan

## Applying the plan

The repository also includes a separate OpenTofu configuration in `./nfs-server/` for provisioning an NFS server VM on Proxmox.

From the repository root you can use:

```bash
make nfs-up
make nfs-down
```

Useful NFS-specific targets:

```bash
make nfs-init
make nfs-plan
make nfs-apply
make nfs-destroy
```

## Retrieving the config files

Before you can do anything with either talos or kubernetes at the commandline you'll need to pull the configuration files from the provisioned cluster.  There are two configuration files that are needed.

1. The talosconfig file that provides configuration information on the provisioned talos cluster itself for the commandline utillity talosctl and 
2. The kubeconfig file that provides configuration information and user authentication for the kubernetes commandline utility kubectl

A convenience script has been created and made available in the `./scripts/` folder called `get-configs.sh` or `get-configs.ps1`

From the repository root you can run:

```bash
./scripts/get-configs.sh
source ./scripts/set-k8s-envvars.sh
```

###  Getting the talos config file
Run the following command in a bash prompt to get the talosconfig file.

```bash
tofu output -raw talos_config > talosconfig
```

This should create a file in the current directory containing the talos cluster configuration and SSL cert information.

###  Getting the kube config file
Run the following command in a bash prompt


```bash
tofu output -raw kubeconfig > kubeconfig
```

This should create a file in the current directory containing the kube configuration and user identity information.
