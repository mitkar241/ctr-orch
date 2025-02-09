#!/usr/bin/env bash

# docker
docker rmi my-cpp-app:latest 2> /dev/null

# k3s
sudo k3s ctr images rm docker.io/library/my-cpp-app:latest 2> /dev/null
