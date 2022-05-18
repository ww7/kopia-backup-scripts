#!/usr/bin/env bash

set -euo pipefail
# set -x

script_dir="$( cd "$( dirname "$0" )" && pwd )"
source $script_dir/config
# `config` overwrites: 
# repo_main="u281892@u281892.your-storagebox.de:23"
# repository_folder="/home/kopia/json"

repo="$repo_main"
keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"

username=${repo%%@*} 
host=$(echo $repo | sed 's/.*@//' | sed 's/:/\t/g' | awk '{print $1}')
port=$(echo $repo | sed 's/.*://')

[[ -n $(grep "$host" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p $port $host >> "$knownhosts"  2> /dev/null

kopia repository connect sftp \
  --config-file "$script_dir/repositories/repo-$username@$host.config" \
  --cache-directory	"$script_dir/cache/" \
  --username $username \
  --host $host \
  --port $port \
  --keyfile $keyfile \
  --known-hosts $knownhosts \
  --path $repository_folder

# kopia repository validate-provider

echo "Repository: $repo connected and active"