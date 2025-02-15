#!/bin/bash

set -e
set -x

helm  uninstall eso --ignore-not-found

helm -n external-secrets uninstall external-secrets --ignore-not-found
kubectl delete pvc --all -n external-secrets
kubectl delete namespace external-secrets --ignore-not-found=true
