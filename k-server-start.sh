#!/usr/bin/env bash

# Docs: https://kopia.io/docs/reference/command-line/common/server-start/

set -euo pipefail
# set -x

source config

ip=$(curl -s -4 ifconfig.co)

kopia server start --insecure --server-password $ui-password --server-username	$ui-username --ui --address http://$ip:1515