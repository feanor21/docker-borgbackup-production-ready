#!/bin/bash
echo 'start initialisation'
borg break-lock /root/destination

ID=$(/usr/bin/curl -XGET $ELASTIC_ADDR/borg_log/$NAME/_search?pretty=true -d '{"fields":["_id"],"query": {"match_all": {}},"sort":{"date": "desc"},"size": 1}' |grep _id |cut -f2 -d ':'|cut -f1 -d ',' |sed 's/"//g')
if [[ -z $ID ]]
then
ID=1
else
ID=$(($ID+1))
fi



/usr/bin/curl -XPUT "$ELASTIC_ADDR/borg_log/$NAME/$ID" -d "{
\"hostname\": \"$HOST\",
\"instance\": \"$NAME\",
\"date\": \"$(date +%Y-%m-%dT%H:%M:%S)\",
\"status\": \"started\"
}" 
ID=$(($ID+1))
if [ -f /root/log/error.log ]
then
 echo "$(date +%Y-%m-%d:%H:%M:%S) restarting backup" >>/root/log/error.log
fi

if [ -f /root/destination/README ]
then
if [ "$(ls -A /root/origin/)" ]; 
then

	echo 'borg repository already initalised, switching the step'
	  /usr/bin/curl -XPUT "$ELASTIC_ADDR/borg_log/$NAME/$ID" -d "{
  \"hostname\": \"$HOST\",
  \"instance\": \"$NAME\",
  \"date\": \"$(date +%Y-%m-%dT%H:%M:%S)\",
  \"status\": \"starting_backup\"
  }"
  ID=$(($ID+1))
	borg create -v -p -s --ignore-inode --exclude-if-present 'no-backup.ignore' /root/destination::"$NAME#$(date +"%d-%m-%y_at_%H:%M:%S")" /root/origin/ >> /root/log/borg.log 2>&1 

  /usr/bin/curl -XPUT "$ELASTIC_ADDR/borg_log/$NAME/$ID" -d "{
  \"hostname\": \"$HOST\",
  \"instance\": \"$NAME\",
  \"date\": \"$(date +%Y-%m-%dT%H:%M:%S)\",
  \"status\": \"success\"
  }"
  ID=$(($ID+1))
else
  echo "$(date +%Y-%m-%d:%H:%M:%S) origin is empty, container need to be restart  ">> /root/log/error.log
  	/usr/bin/curl -XPUT "$ELASTIC_ADDR/borg_log/$NAME/$ID" -d "{
\"hostname\": \"$HOST\",
\"instance\": \"$NAME\",
\"date\": \"$(date +%Y-%m-%dT%H:%M:%S)\",
\"status\": \"failed  \"
}" 
ID=$(($ID+1))
  fi



else
	echo 'initialising borg repository'
	/usr/bin/curl -XPUT "$ELASTIC_ADDR/borg_log/$NAME/$ID" -d "{
\"hostname\": \"$HOST\",
\"instance\": \"$NAME\",
\"date\": \"$(date +%Y-%m-%dT%H:%M:%S)\",
\"status\": \"initializing\"
}" 
ID=$(($ID+1))
	borg init /root/destination -e none

fi


touch /root/log/borg.log 

sed -i "1s/^/NAME=$NAME\n/" /root/save.sh 
sed -i "1s/^/HOST=$HOST\n/" /root/save.sh 
crontab /root/save.sh
service cron start 
tail -f /root/log/borg.log


