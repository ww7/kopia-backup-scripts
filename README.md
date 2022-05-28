Description
=====

This repository contains Bash scripts toolset for [Kopia](https://kopia.io/docs/) backups.

> Kopia is a simple, cross-platform tool for managing encrypted backups in the cloud. It provides fast, incremental backups, secure, client-side end-to-end encryption, compression and data deduplication.

_**Current version adopted for storing backup repositories on Hetzner StorageBox (over SFTP)**_

_Demo Hetzner StorageBox'es: `u281891@u281891.your-storagebox.de u281892@u281892.your-storagebox.de`_

_Demo server: `104.131.96.248`, database editor Adminer: http://104.131.96.248:8080/_

Installation
---

Dependecies: `git`

1. Open Terminal locally or connect to remote Linux server (Ubuntu/Debian) via SSH
2. Scripts download `git clone --depth=1 https://github.com/ww7/kopia-scripts.git`  
3. Dependencies instalation `bash ./kopia-scripts/kopia-prepare.sh` 
4. (optional) Reopen Terminal or reconnect to remote SSH (to reload environment variable PATH)

Configuration
---

Parameters and environment variables stored in `config` file.

All paramenetrs can be reassigned inside script (place after `source config`).

Scripts 
---

- `k-prepare.sh` performs:
  > Require: running from "root" or "sudo"
  - install of software dependencies and Kopia (for Linux Ubuntu/Debian)
  - generate SSH key for Kopia autorization to remote repositories based on SFTP/SSH
  - import SSH key to Hetzner StorageBox'es (listed in `box` variable), add hosts to known_hosts
  - add scripts path to env
  

- `k-repo-create-sftp.sh` – create repositary and save separate config file for futher connections.

- `k-repo-connect-sftp.sh` – connect to existing repositary, making it as active (main).

- `k-repo-sync-add-sftp.sh` – add SFTP for data replication (synchronization) from main repository and save separate config files for futher connections.

- `k-repo-sync.sh` – sync repositories data, from _repo_main_ to _repo_sync_.

- `k-server-start.sh` – draft version for run Kopia web dashboard UI 

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

Quick start for DB backup with `kopia` (Postgres in Docker)
---
```sh
# set password to ENV `export KOPIA_PASSWORD="pass"` or `source <kopia-scripts>/config`
mkdir -p examples/tmp/

# check repository status  
kopia repository status

# create container with Postgres example database 
docker-compose -f ./pg-create-example-docker.yml up -d

# dump database to file
docker exec -i kopia-scripts_db_1 pg_dump -U test > examples/tmp/test.sql

# container stop and remove
docker-compose -f ./pg-create-example-docker.yml stop
docker-compose -f ./pg-create-example-docker.yml rm -f

# create snapshot of examples/tmp/test.sql
kopia snapshot create examples/tmp/test.sql # <path to file or folder what need to backup>

# list of snapshots for file
kopia snapshot list examples/tmp/test.sql

# restore from selected ID
kopia snapshot restore <ID> examples/tmp/test-restored.sql

# or get last shapshot ID and restore it
kopia snapshot restore $(kopia snapshot list examples/tmp/test.sql --json | jq '.[].id' | tail -n 1) examples/tmp/test-restored.sql

# create container with Postgres restored example database
docker-compose -f ./pg-restore-example-docker.yml up -d
```

Postgres export/import with Docker examples 
---

> https://hub.docker.com/_/postgres

> "docker-entrypoint-initdb.d/" accept only text format dump

Tools can be used: `psql`, `pgcli`, `pg_dump`, `pg_restore`, `createdb`, `dropdb` etc

```sh
# dump from Docker container
docker exec -i kopia-scripts_db_1 pg_dump -U test > test.sql
# dump from $PGHOST
pg_dump postgresql://test:test@$PGHOST:5432/test > test.sql

# database restore with cleanup to Docker container from custom-format dump
docker exec -i kopia-scripts_db_1 pg_restore --clean -U test -h $PGHOST -p 5432 -d test example-custom-format.sql
# database restore with DB creation to Docker container from custom-format dump
docker exec -i kopia-scripts_db_1 pg_restore --create --clean -U test -h $PGHOST -p 5432 -d template1 example-custom-format.sql

# import text format dump
docker exec -i kopia-scripts_db_1 psql -U test < example.sql

# database restore with re-create to $PGHOST
psql postgresql://test:test@$PGHOST:5432/template1 -c 'drop database test;'
psql postgresql://test:test@$PGHOST:5432/template1 -c 'create database test with owner test;'
psql --set ON_ERROR_STOP=on postgresql://test:test@$PGHOST:5432/test < test.sql
```

## Additional information
### Postgres Docker variables
```dockerfile
    environment:
      - POSTGRES_USR="someuser"
      - POSTGRES_PWD="somepwd"
      - POSTGRES_DB="somedb"
      - POSTGRES_URL="postgres://${POSTGRES_USR}:${POSTGRES_PWD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
```
### Postgres Docker volumes
```dockerfile
    volumes:
    # docker-entrypoint-initdb.d/ scipts only runs when `pgdata` directory is empty
      - ./examples/postgres/example.sql:/docker-entrypoint-initdb.d/import.sql
      - ./examples/postgres/script-example.sh:/docker-entrypoint-initdb.d/startup.sh
    # mount `pgdata` to custom path
      - ./examples/postgres/pgdata:/var/lib/postgresql/data
```


### Standalone environment variables
> https://www.postgresql.org/docs/current/libpq-envars.html
```
export PGDATABASE=
export PGUSER=
export PGPASSWORD=
export PGHOST=
export PGPORT=5432
```

### Other Docker Postgres container examples:
```
cat ${BACKUP_SQL_File} | docker exec -i ${CONTAINER_NAME} pg_restore \
    --verbose \
    --clean \
    --no-acl \
    --no-owner \
    -U ${USER} \
    -d ${DATABASE}
```

### Docker tips:
```
# find IP of container
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kopia-scripts_db_1
```

### Notes:
```sh
# `pg_dump` https://www.postgresql.org/docs/current/backup-dump.html
# dump a database into a custom-format archive file
pg_dump -Fc mydb > db.dump
# dump a database into a directory-format archive
pg_dump -Fd mydb -f dumpdir

# `dropdb` drop database 
PGPASSWORD=test dropdb -U test -h $PGHOST -p 5432 test

# `pg_restore` https://www.postgresql.org/docs/current/app-pgrestore.html
# import
PGPASSWORD=test pg_restore -U test -h $PGHOST -p 5432 -d test example-custom-format.sql
# clean and import
PGPASSWORD=test pg_restore --clean -U test -h $PGHOST -p 5432 -d test example-custom-format.sql
# create and import
PGPASSWORD=test pg_restore --create -U test -h $PGHOST -p 5432 -d template1 example-custom-format.sql
# drop, create, import
PGPASSWORD=test pg_restore --create --clean -U test -h $PGHOST -p 5432 -d template1 example-custom-format.sql
```

Kopia Policies example
---
```
kopia policy set --global \
    --keep-annual 0 \
    --keep-monthly 0 \
    --keep-weekly 52 \
    --keep-daily 30 \
    --keep-hourly 0 \
    --keep-latest 5
```

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
