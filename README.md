Backup software README
======================


### Software information ###

We use the [BorgBackup](https://borgbackup.readthedocs.io/en/stable/index.html) open source software, a fork of the [Attic](https://attic-backup.org/) open source project.

We selected this software based on a comparison of the linux backup softwares available on the [ArchLinux Wiki](https://wiki.archlinux.org/index.php/Synchronization_and_backup_programs)

The goal here is to deploy multiple backup on machines, and to monitor their output.

The container create log and send status information to elasticsearch. If there is no elasticsearch to get the status information, the jobs will still run.


### Configuration ###

The configuration is made using the "docker-compose.yml" file.

By default, this container make backup with no compression and no encryption. This can be change using the following environnement variables:

BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK 
  Possible values: yes, no 
  default: yes
BORG_PASSPHRASE
  Possible values: any
  Default: default

BORG_COMPRESSION
  Possible values: a shell argument for borg supported by the borg version. 
  
  examples:
  ```
  BORG_PASSPHRASE='-C lz4';
  ORG_PASSPHRASE='-C zlib';
  ```


ELASTIC_ADDR
  The full adresse of the elasticsearch server to send data
  Default=http://127.0.0.1:9200

NAME
  The backup name display on the elasticsearch logs
  Default: MyBackup
  
HOST
  The hostname displayed for the elasticsearch server
  Default: MyServerName


### Docker image building ###


```
make build
```

### Docker container building ###

The docker container must be built mounting the origin and backup directories.
To build and immediately stop the container, run the following command :

```
docker-compose -f docker-compose.yml up -d
```

after launch it, data will me automatically saved from origin too destination each hour.

Automatic backup setup
----------------------



### Add backup command ###
To do a backup from a directory to a repository, run the command :

```
borg create --ignore-inode -v -p -s [-C lzma] <repository_path>::<backup_name> <backup_path> [... [<backup_path>]] [... [-e <exclude_pattern>]]
```

`<repository_path>` is the path of the target backup directory.
`<backup_name>` is the name of the backup
`<backup_path>` is the directory to backup
`<exclude_pattern>` is a directory or pattern to exclude



### Restor data from backup ###
These steps had to be done inside of the container, execpt if you have borg installed on the host machine.

It is possible to list the backups saved in a repository, and to list files in a backup

```
borg list /root/destination
borg list /root/destination::<backup_name>
```


### Get information on backup ###
We can get information on the size of a backup

```
borg info -v <repository_path>::<backup_name>
```

### Restore backup ###
The following command will restore a backup in the '/root/restore' directory :

```
borg mount /root/destination /root/restore
borg umount /root/restore
```

