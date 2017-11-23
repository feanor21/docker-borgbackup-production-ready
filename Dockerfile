FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
borgbackup \
cron \
vim \
rsync


ENV BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
ENV BORG_PASSPHRASE='default'


RUN rm -f /root/execute.sh /root/save.sh /root/launch.sh
COPY scripts/execute.sh /root/execute.sh
COPY scripts/save.sh /root/save.sh
COPY scripts/launch.sh /root/launch.sh
RUN chmod +x /root/execute.sh
RUN chmod 644  /root/save.sh
RUN chmod +x /root/launch.sh
RUN crontab /root/save.sh


ENV BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
ENV BORG_PASSPHRASE='default'
ENV ELASTIC_ADDR=http://127.0.0.1:9200
ENV NAME='MyBackup'
ENV HOST='MyServerName'

##add test pour borg init
ENTRYPOINT /root/launch.sh >> /root/log/launch.log 2>&1
