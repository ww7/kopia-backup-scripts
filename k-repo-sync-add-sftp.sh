#!/usr/bin/env bash

# Can promt to set mandatory password for repository encryption 

set -e
set -uo pipefail
# set -x

script_dir="$( cd "$( dirname "$0" )" && pwd )"
source $script_dir/config
# `config` overwrites: 
# boxes_to_sync="u281891@u281891.your-storagebox.de u281891@u281892.your-storagebox.de"
# repository_remote_folder="/home/kopia/json"

keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"

for box in $boxes_to_sync; do 
  [[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $(echo $box | sed 's/.*@//') >> "$knownhosts" 2> /dev/null

  kopia repository sync-to sftp \
    --config-file "$script_dir/repositories/repo-$box.config" \
    --host $(echo $box | sed 's/.*@//') \
    --username ${box%%@*} \
    --keyfile $keyfile \
    --known-hosts $knownhosts \
    --port 23 \
    --path $repository_remote_folder

  # kopia repository validate-provider
done