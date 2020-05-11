# Docker, Supervisor, Nginx and MariaDB (with ExecStartPre and ExecStartPost)
Dockerfile and supporting scripts to create Docker Image with Supervisor, Nginx and MariaDB, with a ExecStartPre and ExecStartPost

##### Build.sh, Run.sh and Exec.sh
Rather crude set of scripts to help developing the Dockerfile. Care! Will delete all your other containers and images

##### Supervisor.conf
[program:mariadb]
command=/usr/local/sbin/docker-mysql-start.sh
This starts as a user root, and thus is effectively offers a Systemd like ExecStartPre before starting Mariadb as user ysql. The program su-exec (https://github.com/ncopa/su-exec) enables this.

[eventlistener:execstartpost-listener]
command=/usr/local/sbin/execstartpost-listener.py mariadb
This Python3 script responds to a Supervisor change event to Running state and where the first command-line option specifies the process to monitor
The Python script then runs the MariaDB upgrade program, followed by docker-mysql-poststart.sh, which runs the Secure Installation SQL


This created as a proof of concept and an exuse to learn about Docker.
##### Notes
Supervisor caches all its files. Thus once an edit is made while within the Docker shell it is necessary to stop and restart the container using the exec.sh script where the data contents of the container are preserved.
It might be useful therefore to run two copies of Supervisor, the first running as process 1 to start a second supervisor instance to control the applications. This would enable the second supervisor instance to be started and stopped without exiting the container.

May 2020




