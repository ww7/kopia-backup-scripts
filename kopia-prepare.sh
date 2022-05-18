#!/usr/bin/env bash

# Script performs:
# - installation of software dependencies and Kopia (for Linux Ubuntu/Debian)
# - generate SSH key for Kopia autorization to remote repositories based on SFTP/SSH
# - import SSH key to Hetzner StorageBox'es, add hosts to known_hosts
# - add scripts path to env
#
# Require: running from "root" or "sudo"
# Note: operation will be skipped if already done before

source config

# set -e
set -uo pipefail
# set -x

source config
# `config` overwrites: 
# Hetzner StorageBox'es (one or space separated list), syntax: user@hostname
# Uncomment to overwrite StorageBox'es list from 'config' file
# boxes="u281891@u281891.your-storagebox.de u281892@u281892.your-storagebox.de"

# initialization
script_dir="$( cd "$( dirname "$0" )" && pwd )"
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
  apt update && apt install kopia #kopia-ui
  { [[ -f $(which kopia) ]] && echo "Kopia installed to $(which kopia)"; } || { echo "Error: Kopia no installed, check errors" && exit 1; }
fi

# generate SFTP (SSH) key for access to StorageBox'es
[[ -f "$script_dir"/keys/id_kopia ]] || \
ssh-keygen -o -a 100 -t ed25519 -f keys/id_kopia -C "demo key (password-less) for access to Hetzner StorageBox for Kopia" -q -N ""
key=$(cat keys/id_kopia.pub)

# import newly created SSH key to StorageBox'es, add hosts to known_hosts
for box in $boxes; do 
  authorized_keys="$script_dir"/keys/"$box"_authorized_keys
  box_hostname=$(echo $box | sed 's/.*@//')
  [[ -n $(grep "$box" "$script_dir/keys/known_hosts") ]] || ssh-keyscan -p 23 $box_hostname >> "$knownhosts" 2> /dev/null
  scp -q -P 23 "$box":/home/.ssh/authorized_keys "$authorized_keys"
  [[ -n $(grep "$key" keys/"$box"_authorized_keys) ]] && { echo "$box : key already imported" && continue; }
  echo $(cat keys/id_kopia.pub) | tee -a "$authorized_keys"
  echo -e "echo mkdir .ssh \n chmod 700 .ssh \n put "$authorized_keys" .ssh/authorized_keys \n chmod 600 .ssh/authorized_keys" | sftp -q -P 23 "$box" > /dev/null 2>&1
  echo "$box : new key imported" 
done

# add scripts path to evironment 
[[ ":$PATH:" != *":$script_dir:"* ]] && echo "export PATH=$PATH:$script_dir" >>~/.bashrc