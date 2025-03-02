#!/bin/bash

set -e
set -x

helm -n vault uninstall vault --ignore-not-found
kubectl delete pvc --all -n vault
kubectl delete namespace vault --ignore-not-found=true
