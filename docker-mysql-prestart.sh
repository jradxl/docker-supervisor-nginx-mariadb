#!/bin/bash

logfile=/var/log/mysql/docker-prestart.log

now=`date +%Y-%m-%d.%H:%M:%S`
echo "pre-init starting now: $now" >> $logfile 2>&1

chown -R mysql:mysql /var/lib/mysql >> $logfile 2>&1

echo "pre-init finished" >> $logfile 2>&1
##exit 0
