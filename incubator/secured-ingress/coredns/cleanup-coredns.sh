#!/bin/bash

set -e
set -x

kubectl -n kube-system patch cm coredns --type merge --patch "$(cat coredns/corefile-default.yaml)"
kubectl -n kube-system rollout restart deployment/coredns
