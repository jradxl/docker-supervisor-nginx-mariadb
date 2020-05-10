#!/bin/bash

num=$(docker container ls -aq) 
if [[ $num ]]; then
    docker container stop $(docker container ls -aq) >/dev/null
    docker container rm $(docker container ls -aq) >/dev/null
else
    echo "None to stop and/or remove ..."
fi
docker ps
docker container ls -a

