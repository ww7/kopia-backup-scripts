#!/usr/bin/env bash

# Can promt to set mandatory password for repository encryption 

set -e
set -uo pipefail
# set -x

script_dir="$( cd "$( dirname "$0" )" && pwd )"
source $script_dir/config
# `config` overwrites: 
# repo_sync="u281891@u281891.your-storagebox.de:23 u281891@u281892.your-storagebox.de:23"
# repository_folder="/home/kopia/json"

keyfile="$script_dir/keys/id_kopia"
knownhosts="$script_dir/keys/known_hosts"


repo_main=$(echo $repo_main | sed 's/@/\t/g' | sed 's/:/\t/g' | awk '{print $1"@"$2}')
kopia repository connect from-config --file "$script_dir/repositories/repo-$repo_main.config"

for repo in $repo_sync; do 
  
  username=${repo%%@*} 
  host=$(echo $repo | sed 's/.*@//' | sed 's/:/\t/g' | awk '{print $1}')
  port=$(echo $repo | sed 's/.*://')

  [[ -n $(grep "$host" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p $port $host >> "$knownhosts"  2> /dev/null
 
  # temporary workaround Kopia bug of `kopia repository sync-to sftp`
  # kopia repository create sftp \
  #   --config-file "$script_dir/repositories/repo-$username@$host.config" \
  #   --cache-directory	"$script_dir/cache/" \
  #   --username $username \
  #   --host $host \
  #   --port $port \
  #   --keyfile $keyfile \
  #   --known-hosts $knownhosts \
  #   --path $repository_folder
  # #echo -e "rm -r $repository_folder" | 
  # eval `ssh-agent -s`
  # ssh-add $keyfile
  # lftp -e "rm -r $repository_folder" -p $port "$username@$host" #> /dev/null 2>&1

  kopia repository sync-to sftp \
    --username $username \
    --host $host \
    --port $port \
    --keyfile $keyfile \
    --known-hosts $knownhosts \
    --path $repository_folder \
    --delete
    # --config-file "$script_dir/repositories/repo-$username@$host.config"

  # kopia repository validate-provider
done