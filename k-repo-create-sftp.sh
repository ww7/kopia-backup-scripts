#!/usr/bin/env bash

# Can promt to set mandatory password for repository encryption 

# set -e
set -uo pipefail
set -x

source config
# boxes="u281891.your-storagebox.de u281892.your-storagebox.de"
# repository_remote_folder="/home/kopia/json"

script_dir="$( cd "$( dirname "$0" )" && pwd )"
keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"

for box in $boxes; do 
  [[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $box >> "$knownhosts" 2> /dev/null

  kopia repository create sftp \
    --config-file "$script_dir/repositories/repo-$box.config" \
    --cache-directory	"$script_dir/cache/" \
    --host $box \
    --username ${box%%.*} \
    --keyfile $keyfile \
    --known-hosts $knownhosts \
    --port 23 \
    --path $repository_remote_folder

  # kopia repository validate-provider
done