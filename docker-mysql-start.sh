#!/bin/bash

logfile=/var/log/mysql/docker-start.log

now=`date +%Y-%m-%d.%H:%M:%S`
echo $now >> $logfile

##These are run by SupervisorD as root
mariadb-install-db  --datadir=/var/lib/mysql >> $logfile 2>&1
chown -R mysql:mysql /var/lib/mysql >> $logfile 2>&1

echo "Starting Mariadb..." >> $logfile 2>&1

## MySql is started as mysql, using su-exec
exec /usr/local/sbin/su-exec mysql /usr/sbin/mariadbd --defaults-file=/etc/mysql/my.cnf

