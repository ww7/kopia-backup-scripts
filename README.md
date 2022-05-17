Description
=====

This repository contains Bash scripts toolset for [Kopia](https://kopia.io/docs/) backups.

> Kopia is a simple, cross-platform tool for managing encrypted backups in the cloud. It provides fast, incremental backups, secure, client-side end-to-end encryption, compression and data deduplication.

_**Current version adopted for storing backup repositories on Hetzner StorageBox (over SFTP)**_

_Demo Hetzner StorageBox'es: "u281891.your-storagebox.de u281892.your-storagebox.de"_

Installation
---

Dependecies: `git`

1. Open Terminal locally or connect to remote Linux server (Ubuntu/Debian) via SSH
2. Run `git clone --depth=1 <repo_url>` to fetch this repo
3. Run `bash ./<repo_name>/kopia-prepare.sh` to install Kopia and dependencies
4. Open new local Terminal or reconnect to remote SSH (for environment reload)

Scripts 
---

`kopia-prepare.sh` script performs:
- installation of software dependencies and Kopia (for Linux Ubuntu/Debian)
- generate SSH key for Kopia autorization to remote repositories based on SFTP/SSH
- import SSH key to Hetzner StorageBox, add hosts to known_hosts
- add scripts path to env

> Require: running from "root" or "sudo".

> Note: operation will be skipped if already done before.

`k-repo-create-sftp.sh` script to create repositaries
> Require: will promt to set mandatory password for repository encryption 

`k-repo-create-sftp.sh` script to connect existing repositaries
> Require: will promt the password for repository dencryption

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


Links
---

* Read the [Getting Started Guide](https://kopia.io/docs/getting-started/) for a step-by-step walkthrough of using Kopia
* Go to the [Installation](https://kopia.io/docs/installation/) page to get latest kopia release
* Have a look at the [repositories](https://kopia.io/docs/Repositories/) page to repositories usage examples
* Check out some of Kopia's unique [Features](https://kopia.io/docs/features/) including deduplication and encryption
* Learn about the [Architecture](https://kopia.io/docs/advanced/architecture/) of Kopia
* Find more details about command line [Reference](https://kopia.io/docs/reference/command-line/) section.