#!/usr/bin/env bash

# Script performs:
# - installation of software dependencies and Kopia (for Linux Ubuntu/Debian)
# - generate SSH key for Kopia autorization to remote repositories based on SFTP/SSH
# - import SSH key to Hetzner StorageBox'es, add hosts to known_hosts
# - add scripts path to env
#
# Require: running from "root" or "sudo"
# Note: operation will be skipped if already done before

set -e
set -uo pipefail
# set -x

script_dir="$( cd "$( dirname "$0" )" && pwd )"
source $script_dir/config
# `config` overwrites: 
# Hetzner StorageBox'es (one or space separated list), syntax: user@host
# Uncomment to overwrite StorageBox'es list from 'config' file
# repositories="u281891@u281891.your-storagebox.de u281892@u281892.your-storagebox.de"

# initialization
cd $script_dir || { echo "Error: keys directory inaccessible" && exit 1; }
chmod +x *.sh
[[ -d keys ]] || mkdir keys || { echo "Error: can't create directory, check permissions of script's folder"; exit 1; }
[[ -d repositories ]] || mkdir repositories
[[ -d cache ]] || mkdir cache
knownhosts="$script_dir/keys/known_hosts"

# install Kopia from official repository
if [[ ! -f $(which kopia) ]]; then
  curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /usr/share/keyrings/kopia-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list
  apt update && apt install kopia lftp -y #kopia-ui
  { [[ -f $(which kopia) ]] && echo "Kopia installed to $(which kopia)"; } || { echo "Error: Kopia no installed, check errors" && exit 1; }
fi

# generate SFTP (SSH) key for access to StorageBox'es
[[ -f "$script_dir"/keys/id_kopia ]] || \
ssh-keygen -o -a 100 -t ed25519 -f keys/id_kopia -C "demo key (password-less) for access to SFTP storage for Kopia" -q -N ""
key=$(cat keys/id_kopia.pub)

# import newly created SSH key to StorageBox'es, add hosts to known_hosts
repositories="${repo_main} ${repo_sync}"

for repo in $repositories; do 
  username=${repo%%@*} 
  host=$(echo $repo | sed 's/.*@//' | sed 's/:/\t/g' | awk '{print $1}')
  port=$(echo $repo | sed 's/.*://')
  authorized_keys="$script_dir"/keys/"$username@$host"_authorized_keys
  [[ -n $(grep "$host" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p $port $host >> "$knownhosts" 2> /dev/null
  scp -q -P $port "$username@$host":/home/.ssh/authorized_keys "$authorized_keys"
  [[ -n $(grep "$key" keys/"$username@$host"_authorized_keys) ]] && { echo "$repo : key already imported" && continue; }
  echo $(cat keys/id_kopia.pub) | tee -a "$authorized_keys"
  echo -e "echo mkdir .ssh \n chmod 700 .ssh \n put "$authorized_keys" .ssh/authorized_keys \n chmod 600 .ssh/authorized_keys" | sftp -q -P $port "$username@$host" > /dev/null 2>&1
  echo "$repo : key imported" 
done

# add scripts path to evironment 
[[ ":$PATH:" != *":$script_dir:"* ]] && echo "export PATH=$PATH:$script_dir" >>~/.bashrc