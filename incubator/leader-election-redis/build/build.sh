#!/usr/bin/env bash

# docker
docker build -t my-cpp-app:latest -f build/Dockerfile.cpp .

# k3s
docker save my-cpp-app:latest | sudo k3s ctr images import -
