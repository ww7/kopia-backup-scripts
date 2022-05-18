Description
=====

This repository contains Bash scripts toolset for [Kopia](https://kopia.io/docs/) backups.

> Kopia is a simple, cross-platform tool for managing encrypted backups in the cloud. It provides fast, incremental backups, secure, client-side end-to-end encryption, compression and data deduplication.

_**Current version adopted for storing backup repositories on Hetzner StorageBox (over SFTP)**_

_Demo Hetzner StorageBox'es: `u281891@u281891.your-storagebox.de u281892@u281892.your-storagebox.de`_

Installation
---

Dependecies: `git`

1. Open Terminal locally or connect to remote Linux server (Ubuntu/Debian) via SSH
2. Run `git clone --depth=1 https://github.com/ww7/kopia-scripts.git` to fetch this repo
3. Run `bash ./kopia-scripts/kopia-prepare.sh` to install Kopia and dependencies
4. (optional) Open new local Terminal or reconnect to remote SSH (for environment reload)

Configuration
---

Parameters and environment variables for scripts stored in `config` file.
All paramenetrs can be overwritten inside every script (place after `source config`).

Scripts 
---

`k-prepare.sh` performs:
> Require: running from "root" or "sudo". Note: operation will be skipped if already done before.
- install of software dependencies and Kopia (for Linux Ubuntu/Debian)
- generate SSH key for Kopia autorization to remote repositories based on SFTP/SSH
- import SSH key to Hetzner StorageBox'es (listed in `box` variable), add hosts to known_hosts
- add scripts path to env

`k-repo-create-sftp.sh` – create repositary and save separate config file for futher connections.

`k-repo-connect-sftp.sh` – connect to existing repositary, making it as active (main).

`k-repo-sync-add-sftp.sh` – add SFTP for data replication (synchronization) from main repository and save separate config files for futher connections.

`k-repo-sync.sh` – sync repositories data, from _repo_main_ to _repo_sync_.

`k-server-start.sh` – draft version for run Kopia web dashboard UI 

Quick start
---

### Steps for first run:
1. Edit `config` file (or use provided example):
- `repo_main` (required), – main SFTP repository storage (syntax: user@host)
- `repo_sync` (optional) – additional storages for main repository replication/sync (one or space separated list) 
- `repository_folder` (reqired) – path where repository folder placed on storage
- `KOPIA_PASSWORD` (reqired) – password for repositories encryption
2. Run `k-prepare.sh` for instalation and initialization (it needs to run again if new remote storage's added). First time password for remote user@storage_host can be asked
3. Create repository (main, master) with `k-repo-create-sftp.sh`
4. Add folders or files with `kopia snapshot create [source (path to file or folder)]`

### Next:
- add new SFTP storage's for main repository replication (sync) with `k-repo-sync-add-sftp.sh`
- use `k-repo-sync.sh` to sync data to additional storage's
- use `k-repo-connect-sftp.sh` to make other repository active (main)

### File `config` stores configuration for Kopia, as: 
- list of remote storage's
- default password for repository encryption
- other options and variables

Essential CLI commands
---

### Common Commands
- [`diff`](https://kopia.io/docs/reference/command-line/common/diff/) - Displays differences between two repository objects (files or directories)
- [`list`](https://kopia.io/docs/reference/command-line/common/list/) - List a directory stored in repository object
- [`restore`](https://kopia.io/docs/reference/command-line/common/restore/) - Restore a directory or a file
- [`show`](https://kopia.io/docs/reference/command-line/common/show/) - Displays the contents of a repository object
- [`mount`](https://kopia.io/docs/reference/command-line/common/mount/) - Mount repository object as a local filesystem

### Commands to manipulate snapshots
- [`snapshot copy-history`](https://kopia.io/docs/reference/command-line/common/snapshot-copy-history/) - Performs a copy of the history of snapshots from another user or host
- [`snapshot move-history`](https://kopia.io/docs/reference/command-line/common/snapshot-move-history/) - Performs a move of the history of snapshots from another user or host
- [`snapshot create`](https://kopia.io/docs/reference/command-line/common/snapshot-create/) - Creates a snapshot of local directory or file
- [`snapshot delete`](https://kopia.io/docs/reference/command-line/common/snapshot-delete/) - Explicitly delete a snapshot by providing a snapshot ID
- [`snapshot estimate`](https://kopia.io/docs/reference/command-line/common/snapshot-estimate/) - Estimate the snapshot size and upload time
- [`snapshot expire`](https://kopia.io/docs/reference/command-line/common/snapshot-expire/) - Remove old snapshots according to defined expiration policies
- [`snapshot list`](https://kopia.io/docs/reference/command-line/common/snapshot-list/) - List snapshots of files and directories
- [`snapshot migrate`](https://kopia.io/docs/reference/command-line/common/snapshot-migrate/) - Migrate snapshots from another repository
- [`snapshot pin`](https://kopia.io/docs/reference/command-line/common/snapshot-pin/) - Add or remove pins preventing snapshot deletion
- [`snapshot restore`](https://kopia.io/docs/reference/command-line/common/snapshot-restore/) - Restore a directory or a file
- [`snapshot verify`](https://kopia.io/docs/reference/command-line/common/snapshot-verify/) - Verify the contents of stored snapshot

More: [Kopia CLI reference](https://kopia.io/docs/reference/command-line/)

Links
---

* Read the [Getting Started Guide](https://kopia.io/docs/getting-started/) for a step-by-step walkthrough of using Kopia
* Go to the [Installation](https://kopia.io/docs/installation/) page to get latest kopia release
* Have a look at the [repositories](https://kopia.io/docs/Repositories/) page to repositories usage examples
* Check out some of Kopia's unique [Features](https://kopia.io/docs/features/) including deduplication and encryption
* Learn about the [Architecture](https://kopia.io/docs/advanced/architecture/) of Kopia
* Find more details about command line [CLI reference](https://kopia.io/docs/reference/command-line/).
