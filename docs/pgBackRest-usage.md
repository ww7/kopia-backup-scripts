## HOW to setup pgBackRest, is there a docker image?
1. Install as package `apt install pgbackrest` / `yum install pgbackrest` (recommended and simplest way, updated frequently)
2. Build from the source (cost a time and disk space for dependencies)
3. Run with Docker [prebuilt images](https://hub.docker.com/search?q=pgBackRest)

## HOW to configure pgBackRest to take first backup of test DB (created for `pg_dump` test)

>NOTE: `pgbackrest` works locally or via SSH protocol, connection to `postgresql://` protocol not supported (default 5432 port).
To use it with containerized Postgres (Docker) `pgbackrest` should be inside `postgresql` container.
Such prebuilt contaner images of `postgresql` and related tools provided by [Crunchy Data Container Suite](https://access.crunchydata.com/documentation/crunchy-postgres-containers/latest/), [Crunchy on Docker Hub](https://hub.docker.com/u/crunchydata), [Crunchy pgBackRest usage examples](https://access.crunchydata.com/documentation/crunchy-postgres-containers/latest/examples/backup-restoration/pgbackrest/) (Crunchy is active contributor of Postgres development and provide production ready Postgres solutions).

>NOTE: Newest `pgBackRest` (> [2.37, February 2022](https://www.postgresql.org/about/news/pgbackrest-237-released-2403/)) versions implements new feature: "TLS server", that allow to communicate between pgBackRest instances with significantly faster performance (more lightweight than SSH) and allows to communicate between different architectures.

1. Allow access for `replication` (binary backup) in `pg_hba.conf`, edit: `host replication all all trust` (`host replication <pg username> <alowed host> trust`). Can be automated by initialization script with command `echo "host replication all all trust" >> /var/lib/postgresql/data/pg_hba.conf`. Authentication method can be changed from passwordless `trust` to e.g. `scram-sha-256`. 
- Added `init.sh` script to Docker Compose yml files. 
2. Create config `/etc/pgbackrest/pgbackrest.conf` (or use CLI parameters) 
- Prepare
```sh
# find postgres data path in container for config "pg1-path"
docker inspect -f '{{range.Mounts}}{{if eq .Type "volume"}}{{println .Source}}{{end}}{{end}}' kopia-scripts_db_1
# create folder for backup repository
mkdir -p /var/lib/pgbackrest
```
- Edit `pgbackrest` config `nano /etc/pgbackrest/pgbackrest.conf`
```sh
[global]
repo1-path=/var/lib/pgbackrest

# Stanza "demo" (is a pgBackRest configuration for certain Postgres database cluster)
[demo]
pg1-path=/var/lib/docker/volumes/1cdbc4c8569f018ee4fb8f3976fb34b11e8458881ec0c09e365452fa4651739c/_data_ # path to Postgres data folder
```
4) (not success) create `stanza` (settings for certain postgres claster/replica in `pgbackrest` terms) and check it
```sh
pgbackrest --stanza=demo stanza-create
pgbackrest --stanza=demo check
# Output: WARN: unable to check pg1: [DbConnectError] unable to connect to 'dbname='postgres' port=5432': connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "root" does not exist
# ERROR: [056]: unable to find primary cluster - cannot proceed

# Note: found it require access to postgresql socket (to be on same instance)
# Conclusion: to work with other host it require a SSH/TLS connection to instance what have preconfigured pgbackrest

# as can't initialize stanza and repository then can't continue for backups
pgbackrest --stanza=demo backup
pgbackrest --stanza=demo --type=full backup # force full backup
#ERROR: [055]: unable to load info file '/var/lib/pgbackrest/backup/demo/backup.info' or '/var/lib/pgbackrest/backup/demo/backup.info.copy':
#       FileMissingError: unable to open missing file '/var/lib/pgbackrest/backup/demo/backup.info' for read
#       FileMissingError: unable to open missing file '/var/lib/pgbackrest/backup/demo/backup.info.copy' for read
#       HINT: backup.info cannot be opened and is required to perform a backup.
#       HINT: has a stanza-create been performed?

# lish of backups
pgbackrest info
```  
5) Conclusion: usage of `pgBackRest` with Docker no very simple, Postgres should be hosted with `SSHD`, or include `pgBackRest`, possible stategies:
- Integrate `pgBackRest` in Postgres container image
- Use prebuilt Postgres container image with `pgBackRest` e.g. [crunchy-postgres](https://access.crunchydata.com/documentation/crunchy-postgres-containers/latest/overview/overview/)
- Use [Crunchy Container suite](https://access.crunchydata.com/documentation/crunchy-postgres-containers/latest/overview/overview/) and [crunchy-pgbackrest](https://access.crunchydata.com/documentation/crunchy-postgres-containers/latest/container-specifications/crunchy-pgbackrest/) (also Dedicated Repository Host mode e.g. in [woblerr/pgbackrest](https://hub.docker.com/r/woblerr/pgbackrest))
- Use Postgres container with `SSHD` enabled (not recommended).
- Learn new `pgBackRest TLS server` connectivity.

## HOW to configure pgBackRest to restore first backup of test DB against fresh DB
Restore operate on cluster level (not a single DB) and will overwrite whole cluster.
To restore from backup:
1. Stop cluster `pg_ctlcluster <version> main stop`
2. Restore
```sh
# restore last incremental
pgbackrest --stanza=demo --log-level-console=info --delta --recovery-option=recovery_target=immediate restore

# restore last full
pgbackrest --stanza=demo --log-level-console=info --delta restore
```
3. Start cluster `sudo pg_ctlcluster <version> main start`
4. Create fresh backup `pgbackrest --stanza=main backup`

## Make a change to test DB
```sh
# using pgbench, let’s create some test data:
pgbench -i -s 100 test
```

## HOW to configure pgBackRest to take incremental backup so that this change is saved
1. Backing up a running PostgreSQL cluster requires WAL archiving to be enabled
- Enable required settings in `postgresql.conf`
```sh
archive_command = 'pgbackrest --stanza=demo archive-push %p'  
archive_mode = on  
log_filename = 'postgresql.log'  
max_wal_senders = 3  # max. number of connections to WAL (default: 10)
wal_level = replica
```
- The PostgreSQL cluster must be restarted after making these changes and before performing a backup.
2. Allow access for `replication` in `pg_hba.conf` (/var/lib/postgresql/data/pg_hba.conf), edit: `host replication all all trust`
3. Configure encryption, compression, retention of incremental and full backups 
- Generate cipher-pass `openssl rand -base64 48` 
- Edit `/etc/pgbackrest/pgbackrest.conf`
```sh
# default settings
[global]
repo1-path=/var/lib/pgbackrest
process-max=2 # multitreading option, how much CPU cores to use
repo1-cipher-pass=...
repo1-cipher-type=aes-256-cbc

[global:archive-push]  
compress-level=3

# Stanza "demo" 
[demo]
pg1-path=/var/lib/pgsql/data # path to Postgres data folder
start-fast=y
stop-auto=y
retention-diff=3 # retention of incremental backups
retention-full=2 # retention of full backups
```
4. Create the Stanza `pgbackrest --stanza=demo stanza-create` (once the repository has been configured and the stanza created and checked, the repository encryption settings cannot be changed)
5. Check repository `pgbackrest --stanza=demo check` and backup `pgbackrest --stanza=demo backup`

## WHAT are the ways to take incremental backup
### Periodic schedule like cron? HOW?
- Edit crontab `crontab -e`
```sh
#pgbackrest backups
00 01 * * 3,6 pgbackrest --stanza=demo --type=full backup
00 01 * * 0-2,4,5 pgbackrest --stanza=demo --type=incr backup
```
- Also it can be done via Linux `systemd` (`backup.service` and `backup.timer`)

### Continuously like streaming replication? HOW?
Main steps as enabling for binary backup with pgBackRest, and [additionally](https://pgbackrest.org/user-guide.html#replication/streaming)
1. Add `password/key access` for replication host in `pg_hba.conf` (address of secondary Postgres server to what replication will be streamed)
2. Check `postgresql.conf` for `listen_addresses = '*'`
3. Create separate user on primary Postgres for replication 
```sh
psql -c "create user replicator password 'PSWRD1' replication";
``` 
4. Restart cluster and check if firewall not block connection to Postgres (default port: 5432) `telnet <host> 5432`
5. Perform fresh full backup with `pgBackRest` `pgbackrest --stanza=demo --type=full backup`
6. Make sure Postgres and pgBackRest installed on secondary server, stop the cluster on secondary
7. Configure `pgbackrest.conf` on secondary to be in `standby_mode` and specify connection details
```sh
[global]
repo1-path=/var/lib/pgbackrest
repo1-retention-full=1
process-max=2
log-level-console=info
log-level-file=debug

[demo]
pg1-path=/var/lib/pgsql/data
recovery-option=standby_mode=on
recovery-option=primary_conninfo=host=<IP or domain address of primary> user=replicator
recovery-option=recovery_target_timeline=latest
```
8. Restore from primary server (run command on secondary) (it also will generate `recovery.conf` with `archive-get %f "%p"')
```sh
pgbackrest --stanza=demo --delta restore
```
9. Start the cluster on secondary

## Take an incremental backup using the simplest/quickest method we have learned
Taking backups is most simple part
```sh
pgbackrest --stanza=demo --type=incr backup
# or just
pgbackrest --stanza=demo backup
```
## Restore this backup to a fresh DB
```sh
# will overwrite whole cluster
pgbackrest --stanza=demo --delta restore
```
## Verify the change made to test DB shows up
```sh
# find IP address of postgres container, set variable
PGHOST=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kopia-scripts_db_1)
# echo content of database `test`
pg_dump postgresql://test:test@$PGHOST:5432/test | less
```


## Other useful commands
- Test if binary backup works with `pg_basebackup`
```sh
# find IP address of postgres container, set variable
PGHOST=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kopia-scripts_db_1)
# bibary dump with `pg_basebackup` via postgresql:// protocol
pg_basebackup --dbname=postgresql://test@$PGHOST:5432 -D /tmp/bdump-test/
```

