#!/bin/sh

set -e
set -x

helm uninstall my-app

sudo sed -i '/^\s*192\.168\.0\.108\s\+my-app\.mitkar\.io\b/d; /^\s*$/d' /etc/hosts
