#!/bin/sh
set -e

echo "Cleaning up test resources..."
kubectl delete pod my-app-client --ignore-not-found=true
