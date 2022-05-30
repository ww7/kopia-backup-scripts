
# Kopia overview

1. Space efficient, Kopia has both deduplication and compression.

    1.1. Deduplication means content-addressable snapshots, which has many benefits:
    - Each snapshot is always incremental, no data included in previous snapshots is ever re-uploaded to the repository.
    - Multiple copies of the same file will be stored once. This is known as de-duplication.
    - After moving or renaming even large files, Kopia can recognize the same content and won’t need to upload them again.
    - Efficient handling of changes to very large files, that will be snapshotted by only uploading the changed parts and not entire file.

    1.2. Compression to save extra storage and bandwidth. Supports modern algorithms such as ZSTD and s2.

2. Encryption of repositories makes it suitable for backups to not fully trusted storages. Uses state-of-the-art encryption algorithms, such as AES-256 or ChaCha20. Master key is encrypted with user-provided passphrase, which is never sent outside.

3. Smart posibilies to reduce storing cost and quick browse the repository contents. Kopia does segregate metadata from data. Directory listings, snapshot manifests and few other minor data pieces are stored in pack files separately. It allows to cache all metadata files locally, that provides fast directory listing, manifest listing and very fast verification without having to download actual data.

4. Optimal price with scaling. Kept metadata separate from the actual data allows to store backup data in AWS S3 Deep Glacier or other "cold" storage at a lowest cost, and still do incremental backups. 

5. Client-side architecture. Kopia performs all its operations without having to maintain dedicated server and supports a variety of storage providers, including cloud storage. 

6. Works with close to all storage backends. Some prices for storages:
    - AWS Deep Glacier 4 TB of data, storing will be ~$50/year (free ingress), if ever need to retrieve the data, it's cost around $370.
    - Wasabi prices 4 TB of data, with 100% of it downloaded every month around $287/year according to their price calculator.
    - Backblaze B2's prices 4 TB of data upload, delete and download only 1TB/month puts out around $360/year. But download of 4TB every month puts at $720/year.
        > cloud storages (blob buckets, object storages) price very depends to amount of data downloaded
    - Hetzner storage boxes offer 10TB for ~$48/month, which is $576 a year -- free ingress/egress, no complicated or hidden fees for operations.

7. Redudancy:

    7.1. Syncronisation of repository to multiple storages

    7.2. Files can be often recovered even after partial loss of repository contents, because key index information and repository metadata is stored redundantly to prevent single points of failure
    
    7.3. Consistency where data structures and algorithms are designed to maintain data consistency even in the event of a hardware failure or software misconfiguration. For example: silent data corruption after write, misconfigured or unsupported filesystem, large clock skew.

8. Rich Command Line Interface for managing snapshots and policies, but also for low-level access to the underlying repository, including low-level data recovery.

9. Kopia provide other neat features:

    9.1. Mountable as filesystems (as local folder) for quick overview and restores.

    9.2. Web-dashboard GUI with HTTP API server that can be used to trigger snapshots, get their status and access snapshotted data.

    9.3. Multi-user (ACL rules) access to different namespaces (separates data).
    
    9.4. Policies for repository cleanup and snapshots scheduling:
    - retention - how long to keep snapshots before expired
    - scheduling - how frequently/when should snapshots be created

    9.5. Actions feature for running custom commands or scripts before and after snapshot root and also before/after individual folders as they get snapshotted. For example: sending notifications, chain of snapshots, filesystem-level snapshots (for e.g. ZFS, Btrfs).

    9.6. Support excludes patterns with .kopiaignore files (like .gitignore).


#### Notes: 

1. Compared to Borg, Kopia is a backup software based on the similar concepts what include: infinite increments, rolling-hash based deduplication, immutable blobs, encryption. But has some things going for it in addition, such as the client-side architecture with support for a wide array of backends, repo synchronization ability (using the same array of backends), the ability to do concurrent backups on the same repo, multi-user, server-mode etc.

2. `q` blobs are very aggressively cached by the Kopia client, so may appear not to be accessed when performing basic operations like listing snapshots etc.


# Links
[Benchmarking Kopia and Borg: Architecture, Scale, and Performance](https://www.kasten.io/kubernetes/resources/blog/benchmarking-kopia-architecture-scale-and-performance) (v0.6.0-rc1 dated July, 2020)