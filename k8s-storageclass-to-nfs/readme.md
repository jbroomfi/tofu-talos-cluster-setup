# README

## Setup storageClass to NFS Server

Create an `values.yaml` file by copying the values.yaml.example and updating it for your local environment.

```yaml
nfs:
  server: nfs-server
  path: /srv/nfs

storageClass:
  create: false
  name: nfs-client
  provisionerName: cluster.local/nfs-subdir-external-provisioner
  defaultClass: false
  reclaimPolicy: Delete
  archiveOnDelete: true

# Optional but recommended
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 65534

securityContext:
  allowPrivilegeEscalation: false

resources: {}
```
Once the values.yaml file has been saved, it can then be used with helm to deploy a default storageClass to the talos-cluster.

```bash
helm repo add nfs-subdir-external-provisioner \
  https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/

helm repo update

helm install nfs-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  -f values.yaml

kubectl apply -f default-storageclass.yaml
```

To verify that the storageClass has been created

# ToDo
[X] Ran into issue last night where nfs-provisioner wasn't initialising correctly.  Eventually identified the issue as the exported nfs share rejecting a connection from the talos node (even though it was wide open).  
[X] Updating the export definition to be scoped to 192.168.10.0/24 and restarting the nfs service resolved the issue.

[ ] Need to finish off this README.md to completing the tests required to confirm correct operation of the nfs-provisioner package.
[ ] Also need to update the nfs-server manaifest to inject a subnet range in place of leaving it wide open.
