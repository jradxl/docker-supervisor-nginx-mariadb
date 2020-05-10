#!/bin/bash

num=$(docker image ls -aq) 
echo "Number: $num"
if [[ $num ]]; then
    docker image rm $(docker image ls -aq) >/dev/null
else
    echo "None to remove ..."
fi
docker images ls -a

