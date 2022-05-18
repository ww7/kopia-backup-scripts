#!/usr/bin/env bash

# Can promt to set mandatory password for repository encryption 

# set -e
set -uo pipefail
# set -x

source config
# `config` overwrites: 
# box_main="u281891@u281891.your-storagebox.de"
# repository_remote_folder="/home/kopia/json"

box="$box_main"
script_dir="$( cd "$( dirname "$0" )" && pwd )"
keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"


  [[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $(echo $box | sed 's/.*@//') >> "$knownhosts" 2> /dev/null

  kopia repository create sftp \
    --config-file "$script_dir/repositories/repo-$box.config" \
    --cache-directory	"$script_dir/cache/" \
    --host $(echo $box | sed 's/.*@//') \
    --username ${box%%@*} \
    --keyfile $keyfile \
    --known-hosts $knownhosts \
    --port 23 \
    --path $repository_remote_folder

  # kopia repository validate-provider
