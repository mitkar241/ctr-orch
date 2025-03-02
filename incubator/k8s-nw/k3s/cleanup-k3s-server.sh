#!/bin/bash

set -e
set -x

sudo /usr/local/bin/k3s-uninstall.sh || true
