Backup software README
======================

Installation
------------

### Software information ###

We use the [BorgBackup](https://borgbackup.readthedocs.io/en/stable/index.html) open source software, a fork of the [Attic](https://attic-backup.org/) open source project.

We selected this software based on a comparison of the linux backup softwares available on the [ArchLinux Wiki](https://wiki.archlinux.org/index.php/Synchronization_and_backup_programs)

### Docker image building ###

The backup software is packaged in an Ubuntu 16.04 docker image.
To build the image, run the following command in the project directory :

```
docker build -t borgbackup docker/unique_server/
```

### Docker container building ###

The docker container must be built mounting the origin and backup directories.
To build and immediately stop the container, run the following command :

```
docker run -id \
    --name borgbackup_container \
    -v <origin_path>:/root/origin \
    -v <repository_path>:/root/destination \
    --privileged \
    borgbackup
docker stop borgbackup_container
```
For the version which integrate a cron scheduler, the command is a little bit different:
```
docker run -d \
--name borgbackup_container \
--restart=always \
-v /<origin_path>:/root/origin \
-v <repository_path>:/root/destination \
-v <log_repository_path>:/root/log \
-h $(hostname) \
--privileged \
borgbackup:stable-v1.0
```
after launch it, data will me automatically saved from origin too destination each hour.

Automatic backup setup
----------------------

### Destination repository creation ###
First we need to initialize a repository to store the backups. 

To run the command through the container package use :
```
docker start borgbackup_container && docker exec -t borgbackup_container borg init /root/destination -e none && docker stop borgbackup_container
```

The general syntax is :
```
borg init <repository_path> -e none
```

The `-e none` parameter disable the encryption.


### Software cron Setup ###
To add the backup job to the crontab you can run the script :

```
sudo chmod +x ./scripts/add_crontab_job.sh
sudo ./scripts/add_crontab_job.sh
```

Other commands for backup management
------------------------------------

### Add backup command ###
To do a backup from a directory to a repository, run the command :

```
borg create --ignore-inode -v -p -s [-C lzma] <repository_path>::<backup_name> <backup_path> [... [<backup_path>]] [... [-e <exclude_pattern>]]
```

`<repository_path>` is the path of the target backup directory.
`<backup_name>` is the name of the backup
`<backup_path>` is the directory to backup
`<exclude_pattern>` is a directory or pattern to exclude

#### Example : ####

```
borg create --ignore-inode -v -p -s -C lzma destination::"backup of $(hostname) : $(date +"%d-%m-%y at %H:%M:%S")" origin/ -e "*.pyc"
```

### Prune backups command ###
This command remove old backups to reclaim disk space.
The command can be run to keep only one backup for each day of the last 7 days, or one backup each week for the last 4 weeks for example.

#### Example : ####
This command will keep the last backups made each day for the past week, each week for the past month, and each months for the past 6 months.

```
borg prune -v <repository_path> --prefix "backup of $(hostname) :" --keep-hourly=168 --keep-daily=14 --keep-weekly=4 --keep-monthly=2000
```

### List backups and file ###
It is possible to list the backups saved in a repository, and to list files in a backup

```
borg list <repository_path>
borg list <repository_path>::<backup_name>
```

#### Example ####

```
docker start borgbackup_container && docker exec -t borgbackup_container borg list /root/destination && docker stop borgbackup_container
```


### Get information on backup ###
We can get information on the size of a backup

```
borg info -v <repository_path>::<backup_name>
```

### Restore backup ###
The following command will restore a backup in the current directory :

```
borg mount /root/destination /root/restore
borg umount /root/restore
```
