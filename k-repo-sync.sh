#!/usr/bin/env bash

# set -e
set -uo pipefail
set -x

source config
# `config` overwrites: 
# boxes_to_sync="u281891@u281891.your-storagebox.de u281891@u281892.your-storagebox.de"
# box_main="u281892@u281892.your-storagebox.de"

script_dir="$( cd "$( dirname "$0" )" && pwd )"
keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"

kopia repository connect from-config --file "$script_dir/repositories/repo-$box_main.config"

for box in $boxes_to_sync; do 
  [[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $box >> "$knownhosts" 2> /dev/null

  kopia repository sync-to from-config --delete --file "$script_dir/repositories/repo-$box.config"
done

