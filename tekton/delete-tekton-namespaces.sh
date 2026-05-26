#!/bin/bash

set -euo pipefail

kubectl delete namespace \
  tekton-pipelines \
  tekton-pipelines-resolvers \
  tekton-dashboard \--ignore-not-found=true --grace-period=0 --force
