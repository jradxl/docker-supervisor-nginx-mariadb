#!/usr/bin/env python3
###############################################
#
# Simple Supervisor ExecStartPost event handler
#
###############################################
import sys
import time
import logging
import subprocess
from supervisor import childutils

def main():

    logging.basicConfig(filename='/var/log/execstartpost-debug.log', level=logging.DEBUG)
    log = logging.getLogger('listener1.main')

    #Your Process_Name should be the only command-line argument    
    n = len(sys.argv)
    if n != 2:
        log.error("ERROR: You must specify the Process_Name that you want this Event Listener to monitor")
        exit(1)

    monitored_process= sys.argv[1]
    
    while 1:   
        headers, payload = childutils.listener.wait()
        if headers['eventname'].startswith('PROCESS_STATE'):
            pheaders = childutils.get_headers(payload)   
            state = headers['eventname'][len('PROCESS_STATE_'):]
            processname = pheaders["processname"]
            if processname ==  monitored_process and state == "RUNNING":
                log.debug("Upgrading MariaDB if necessary!")
                time.sleep(20)
                try:
                    cp=subprocess.run(["mariadb-upgrade"], check=True, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    if cp.returncode != 0:
                        log.debug("ERROR: Running mariadb-upgrade: " + cp.returncode)
                    else:
                        log.debug("STDOUT: " + cp.stdout)
                        if cp.stderr != "":
                            log.debug("STDERR: " + cp.stderr)

                except:
                    log.debug("ERROR upgrading MariaDB: " + sys.exc_info()[0])
                    childutils.listener.ok()
                    exit(1)

                log.debug("Done upgrading MariaDB")
                try:
                    log.debug("Securing MariaDB!")
                    cp=subprocess.run(["/usr/local/sbin/docker-mysql-poststart.sh"], check=True, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    if cp.returncode != 0:
                        log.debug("ERROR: docker-mysql-poststart.sh: " + cp.returncode)
                    else:
                        log.debug("STDOUT: " + cp.stdout)
                        if cp.stderr != "":
                            log.debug("STDERR: " + cp.stderr)
                            
                    log.debug("Done securing MariaDB")

                except:
                    log.debug("ERROR securing MariaDB: " + sys.exc_info()[0])
                    childutils.listener.ok()
                    exit(1)

        childutils.listener.ok()
##End While

if __name__ == '__main__':
    main()

