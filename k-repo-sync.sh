#!/usr/bin/env bash

# set -e
set -uo pipefail
set -x

source config
boxes="u281892.your-storagebox.de"

script_dir="$( cd "$( dirname "$0" )" && pwd )"
keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"

for box in $boxes_to_syncs; do 
  [[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $box >> "$knownhosts" 2> /dev/null

  kopia repository sync-to from-config --delete --file "$script_dir/repositories/repo-$box.config"
done

# --parallel 1/2/3