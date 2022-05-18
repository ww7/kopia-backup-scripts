#!/usr/bin/env bash

# Docs: https://kopia.io/docs/reference/command-line/common/server-start/

ip=$(curl -s -4 ifconfig.co)

kopia server start --insecure --server-password k --server-username	k --ui --address http://$ip:1515