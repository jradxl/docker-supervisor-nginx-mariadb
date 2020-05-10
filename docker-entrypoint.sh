#!/bin/bash

logfile=/var/log/docker-entrypoint.log

if [ "$1" = 'nginx' -o "$1" = 'supervisor' -o "$1" = 'test' ]; then

    # Check for (& run) any prestart init scripts
    if [ -d /usr/local/etc/docker/prestart-init.d ]; then
        #echo "Found dir"  >> $logfile 2>&1
        for f in /usr/local/etc/docker/prestart-init.d/*.sh; do
            #echo "Executing $f ..."  >> $logfile 2>&1
            ##[ -f "$f" ] && . "$f"
            if [ -f "$f" ]; then
                #echo "File found..." >> $logfile 2>&1
                ( "$f" )
                #echo "File done..." >> $logfile 2>&1
            fi
        done
	    #echo "Done..."  >> $logfile 2>&1        
    fi

    if [ "$1" = 'test' ]; then
        echo "test complete..."  >> $logfile 2>&1
        exit 0
    fi

    if [ "$1" = 'supervisor' ]; then
        exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
    else
        exec su-exec nginx "$@"
    fi
fi

exec "$@"

