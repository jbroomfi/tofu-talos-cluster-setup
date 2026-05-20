# Add a terraform linux user account on Proxmox

**Summary**

While using an account secured by an API Token is the most secure approach to working with the Proxmox API via Tofu, there are some operations (e.g. import a disk to a vm) that will only work via a ssh session.  For this reason, we need to setup a new linux user account on the Proxmox host called Terraform and configure it so that it has sudo access on the host.

**Contents**

- [Installing sudo on proxmox](#install-sudo-on-proxmox)
- [Create the terraform user](#create-the-terraform-user)
- [Add a sudo config file for the terraform user](#add-a-sudo-config-file-for-the-terraform-user)
- [Add the terraform user to the sudo group](#add-the-terraform-user-to-the-sudo-group)
- [Create a ssh key for the terraform user](#create-a-ssh-key-for-the-terraform-user)
- [Copy the terraform ssh key to proxmox host](#copy-the-terraform-ssh-public-key-to-the-proxmox-host)
- [Add an alias to the .ssh/config file (optional)](#add-an-alias-to-the-sshconfig-file)

## Install sudo on proxmox
The sudo command isn't installed by default on proxmox so will need to be installed via an apt command;

```bash
apt update && apt install sudo -y
```

## Create the terraform user
To create the new linux user account use the adduser command;

```bash
# adduser terraform
New password: <password>
Retype new password: <confirm password>
Changing the user information for test
Enter the new value, or press ENTER for the default
        Full Name []:
        Room Number []:
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n] 
#
```

## Add a sudo config file for the terraform user
Before the terraform user can start using sudo, two configuration changes are needed.  First we need configure what the terraform user can be using sudo via a configuration file.  

There are two ways in which permissions can be granted, one is by adding an entry directly into the `/etc/sudoers` file, the other is by creating a new file in the folder `/etc/sudoers.d/`.  In this project, we'll use the second approach as it's safer and avoids making any changes directly to the primary `/etc/sudoers` file.  An invalid `/etc/sudoers` file can very effectively break the sudo system.

To do this, we need to create a new text file as `root` in the folder `/etc/sudoers.d/`

```bash
# touch /etc/sudoers.d/terraform
# ls -l /etc/sudoers.d/
total 12
-r--r----- 1 root root 1068 Feb 11 19:22 README
-rw-r--r-- 1 root root    0 May 19 18:29 terraform
-r--r----- 1 root root  666 May 20  2023 zfs
```

Next step is to edit the terraform file and add the following text then save and exit;
```text
terraform ALL=(ALL) NOPASSWD:ALL
```

## Add the terraform user to the sudo group
This is the second configuration change required for sudo to work.  We need to add the `terraform` user to the `sudo` group.

To do this, we need to use the following command;

```bash
# usermod -aG sudo terraform
```

To verify that the `terraform` user now has access to the sudo group, use the `su terraform` command to change to the terraform user and then enter id, this will display the user id and group membership details for the terraform user.  The group sudo should be listed in the groups object.

```bash
# su terraform
terraform@pve:/root$ cd 
terraform@pve:~$ id
uid=1000(terraform) gid=1000(terraform) groups=1000(terraform),27(sudo),100(users)
terraform@pve:~$ 
```

## Create a ssh key for the terraform user
Now we need to create ssh key pair for the terraform user.  

**Note:** This needs to be done from the machine on which the tofu scripts will be executed, **not** on the proxmox host.

To do this, we need to use the ssh-keygen command;

```bash
# ssh-keygen -f terraform
Generating public/private ed25519 key pair.
Enter passphrase for "terraform" (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in terraform
Your public key has been saved in terraform.pub
....
# 
```

This should create two files (the first is the private key, the second is the public key).  Move both the `terraform` and `terraform.pub` files to the folder `~/.ssh`.

## Copy the terraform ssh public key to the proxmox host
Now we need to send a copy of the public key for the terraform user to the Proxmox host so that proxmox can identify the ssh connection without requiring the password to be entered.

To do this we need to use the following command;

```bash
# ssh-copy-id -i ~/.ssh/terraform terraform@<pve-host>
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/admin/.ssh/terraform.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
terraform@<pve-host> password: 

Number of key(s) added: 1

Now try logging into the machine, with: 'ssh -i /home/admin/.ssh/terraform terraform@<pve-host>' and check to make sure that only the key(s) you wanted were added

# 
```

## Add an alias to the .ssh/config file

Strictly speaking this step isn't required for tofu but it is useful if you need to manually check ssh access to the proxmox host.

Adding an alias to the ssh config file allows the terraform user to use a simpler format of the ssh command where they just specify the host alias defined in the config file and ssh will pickup the rest of the options from the config file itself.

Check the folder `~/.ssh` for a file called `config`.  If it exists already you can skip this next action.  If no file exists, then create one using the following commmand;

```bash
touch ~/.ssh/config
```

Now edit the file using a text editor;

```bash
nano ~/.ssh/config
```

Add the following to the config file and save then exit the editor'

```text
Host <Host Alias>
  User terraform
  Hostname <fully qualified domain name>
  IdentityFile ~/.ssh/terraform
```

preNow we can test the alias by using the following command;

```bash
# ssh <Host Alias>
Linux pve-k8s 7.0.2-4-pve #1 SMP PREEMPT_DYNAMIC PMX 7.0.2-4 (2026-05-15T07:32Z) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Tue May 19 18:24:24 2026 from 192.168.10.241
terraform@<pve-host>:~$
```
