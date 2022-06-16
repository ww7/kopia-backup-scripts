Postgres backup solutions
===

## Logical backups: `pg_dump` and `pg_dumpall`
Basical DB dumping, called as "logical", allow to dump structure only, separate tables or certain DB's etc. Makes only full backups. Stored in plain text file with sequence of SQL queries, allow to easy overview, suitable for development and small databases.

#### PROS:
- Easy to use, allow plain text DB dump overview 
- Suitable for development and small databases
- Merging and splitting of databases/clusters
- Small size, effective for compression

#### CONS:
- Slow restore that produce significant system load (for big databases), that can require a separate server
- Lack of features, very basical
- No differential or incremental backups
- No managing of tablespaces

## Binary backups: `pgBackRest`, `wal-e/wal-g`, `pg_probackup`, `barman` etc
Highly functional solutions for backup and recovery of PostgreSQL clusters (based on official tool `pg_basebackup` that hard to use, minimal functionality).

#### PROS:
- Incremental/differential backups 
- Continuous Archiving and Point-in-Time Recovery (PITR) that allows restore to certain date/time
- Deduplication, compression and encryption
- Page-level incremental backup with `pg_probackup` for speed and lowest disk space usage
- Tablespaces managing
- Standby server to avoid extra load on master for backup/restore 
- Streaming replication 
- Validation and verification of backups
- Retention policies for backups merging/wiping
- Optimized parallelization of functions for high speed
- Remotes storages support

#### CONS:
- Require a bigger storage, not less than Postgres cluster size
- Working on `cluster` level, can't restore only certain DB (except `pgBackRest` and `pg_probackup`)

**NOTE**: logical and binary backups can be used together for redudancy and flexibility. 
For example: do quartely `logical` and continuous `binary` backups with `WAL` (Write-Ahead Log) archive of 1 week depth.


Links
---

* [pgBackRest](https://pgbackrest.org/)  - Reliable PostgreSQL Backup & Restore.
* [pg\_probackup](https://github.com/postgrespro/pg_probackup) – A fork of pg\_arman, improved by @PostgresPro, supports incremental backups, backups from replica, multithreaded backup and restore, and anonymous backup without archive command.
* [Barman](https://www.pgbarman.org/index.html) - Backup and Recovery Manager for PostgreSQL by 2ndQuadrant.
* [wal-e](https://github.com/wal-e/wal-e) (obsolete) - Simple Continuous Archiving for PostgreSQL to S3, Azure, or Swift by Heroku.
* [wal-g](https://github.com/wal-g/wal-g) - The successor of WAL-E rewritten in Go. Currently supports cloud object storage services by AWS (S3), Google Cloud (GCS), Azure, as well as OpenStack Swift, MinIO, and file system storages. Supports block-level incremental backups, offloading backup tasks to a standby server, provides parallelization and throttling options. In addition to Postgres, WAL-G can be used for MySQL and MongoDB databases.
* [pitrery](https://dalibo.github.io/pitrery/) - pitrery is a set of Bash scripts to manage Point In Time Recovery (PITR) backups for PostgreSQL.
* [Reddit](https://www.reddit.com/r/PostgreSQL/) - A reddit community for PostgreSQL
* [Slack](https://postgres-slack.herokuapp.com/) - Slack channel for Postgres 
