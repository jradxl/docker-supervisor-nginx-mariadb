#!/bin/bash
docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)
docker image rm test1:testA
docker image prune -af
docker rmi $(docker image ls -aq)
docker system prune -af
docker build -t test1:testA .
docker image ls -a
docker container ls -a

