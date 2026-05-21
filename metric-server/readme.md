helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

##note: for insecure tls##
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set "args={--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}"


##note: for secure tls##
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set "args={--kubelet-preferred-address-types=InternalIP}"

  verify
  kubectl get pods -n kube-system -l "app.kubernetes.io/name=metrics-server"


Panic

  helm uninstall metrics-server -n kube-system