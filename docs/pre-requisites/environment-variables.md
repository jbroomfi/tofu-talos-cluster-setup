# Required Environment Variables

**Summary**

This solution requires a number of environment variables to be defined that either hold configuration information or point to files storing configuration information.

**Contents**

- [Proxmox Identity for integration with Tofu](#proxmox-identity-for-integration-with-tofu)
- [Cluster Configuration](#cluster-configuration)

A convenience script has been created and made available in the `./scripts/` folder called `set-envvars.sh` or `set-envvars.ps1`

## Proxmox Identity for integration with Tofu
To successfully execute the tofu scripts in this solution, you'll need to ensure that you have at a minimum the following environment variables defined.

| Variable | Value | Description |
| -------- | ----- | ----------- |
| PROXMOX_VE_USERNAME | \<user>@pam | The username in Proxmox to use to create VM's with |
| PROXMOX_VE_PASSWORD | \<password> | The password of the user account above |


## Cluster Configuration
Once the talos cluster is up and running and the cluster config files have been retrieved (talsoconfig and kubeconfig), there are two more environment variables that should be defined that point to these config files.

| Variable | Value | Description |
| -------- | ----- | ----------- |
| TALOSCONFIG | `./.kube/talosconfig` | The talos configuration is a yaml formatted file that includes the endpoints, nodes, ssl certs and user identity |
| KUBECONFIG | `./.kube/kubeconfig` | The kubernetes cluster configuration is a yaml formatted file that the command kubectl uses identify the kubernetes cluster, targets and user credentials to use for authentication |

**Example talosconfig yaml file**
```yaml
contexts:
  my-cluster:
    endpoints:
      - 192.168.0.10
    nodes:
      - 192.168.0.10
    ca: <base64-encoded-ca>
    crt: <base64-encoded-client-cert>
    key: <base64-encoded-client-key>
```

**Example kubeconfig yaml file**
```yaml
apiVersion: v1
clusters:
- cluster:
   certificate-authority-data: LS0tL..
   server: https://127.0.0.1:64914
   name: kind-kind
- cluster:
   certificate-authority-data: LS0tLS1C..
   server: https://127.0.0.1:60963
   name: kind-ope
- cluster:
   certificate-authority: /Users/flaviuscdinu/.minikube/ca.crt
   extensions:
   - extension:
       last-update: Thu, 16 Feb 2023 14:50:26 EET
       provider: minikube.sigs.k8s.io
       version: v1.28.0
     name: cluster_info
   server: https://127.0.0.1:49731
   name: minikube
contexts:
- context:
   cluster: kind-kind
   user: kind-kind
 name: kind-kind
- context:
   cluster: kind-ope
   user: kind-ope
 name: kind-ope
- context:
   cluster: minikube
   extensions:
   - extension:
       last-update: Thu, 16 Feb 2023 14:50:26 EET
       provider: minikube.sigs.k8s.io
       version: v1.28.0
     name: context_info
   namespace: default
   user: minikube
 name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: kind-kind
 user:
   client-certificate-data: LS0t…
   client-key-data: LS0t…
- name: kind-ope
 user:
   client-certificate-data: LS0t..
   client-key-data: LS0t…
- name: minikube
 user:
   client-certificate: /Users/flaviuscdinu/.minikube/profiles/minikube/client.crt
   client-key: /Users/flaviuscdinu/.minikube/profiles/minikube/client.key
```
