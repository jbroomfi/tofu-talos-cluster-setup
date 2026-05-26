#!/bin/bash

set -euo pipefail

kubectl apply -f https://infra.tekton.dev/tekton-releases/dashboard/latest/release-full.yaml
kubectl rollout status deployment/tekton-dashboard -n tekton-pipelines --timeout=180s
kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097 &
