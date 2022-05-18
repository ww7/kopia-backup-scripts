#!/usr/bin/env bash

# Docs: https://kopia.io/docs/reference/command-line/common/server-start/

set -euo pipefail
# set -x

script_dir="$( cd "$( dirname "$0" )" && pwd )"
source $script_dir/config

ip=$(curl -s -4 ifconfig.co)

kopia server start --insecure --server-password $ui_password --server-username	$ui_username --ui --address http://$ip:1515