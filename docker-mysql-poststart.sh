#!/bin/bash

logfile=/var/log/mysql/docker-poststart.log

now=`date +%Y-%m-%d.%H:%M:%S`
echo "poststart starting now: $now" >> $logfile 2>&1

##The non-interactive equivalent of mysql_secure_installation
cat <<'EOF' > /tmp/mysql.sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'passw0rd';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE OR REPLACE USER 'test1'@'%' IDENTIFIED BY 'passw0rd';
GRANT ALL ON *.* TO 'test1'@'%';
FLUSH PRIVILEGES;
EOF

echo "Running Secure MariaDB SQL" >> $logfile 2>&1
RET=$(mysql -uroot < /tmp/mysql.sql >> $logfile 2>&1 )
status=$?
echo "mysql status is: $status" >> $logfile 2>&1

echo "poststart finished" >> $logfile 2>&1
exit 0


