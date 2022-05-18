#!/usr/bin/env bash

set -e
set -uo pipefail
# set -x

script_dir="$( cd "$( dirname "$0" )" && pwd )"
source $script_dir/config
# `config` overwrites: 
# repo_sync="u281891@u281891.your-storagebox.de:23 u281891@u281892.your-storagebox.de:23"
# repo_main="u281892@u281892.your-storagebox.de:23"

keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"

kopia repository connect from-config --file "$script_dir/repositories/repo-$repo_main.config"

for repo in $repo_sync; do 
  
  host=$(echo $repo | sed 's/.*@//' | sed 's/:/\t/g' | awk '{print $1}')
  port=$(echo $repo | sed 's/.*://')

  [[ -n $(grep "$host" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p $port $host >> "$knownhosts"  2> /dev/null
 
  kopia repository sync-to from-config --delete --file "$script_dir/repositories/repo-$username@$host.config"

done

