#!/usr/bin/env bash

set -euo pipefail
set -x

source config
box="u281892.your-storagebox.de"
# repository_remote_folder="/home/kopia/json"

script_dir="$( cd "$( dirname "$0" )" && pwd )"
keyfile="$script_dir"/keys/id_kopia
knownhosts="$script_dir/keys/known_hosts"

[[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $box >> "$knownhosts" 2> /dev/null

kopia repository connect sftp \
  --config-file "$script_dir/repositories/repo-$box.config" \
  --cache-directory	"$script_dir/cache/" \
  --host $box \
  --username ${box%%.*} \
  --keyfile $keyfile \
  --known-hosts $knownhosts \
  --port 23 \
  --path $repository_remote_folder

# kopia repository validate-provider
