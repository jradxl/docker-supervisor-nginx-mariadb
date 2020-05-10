#!/bin/bash
docker ps
docker container stop test1:testA
docker container rm test1:testA
docker ps
echo "Running..."
docker run -d \
--name test1-testA \
--volume /host/test1-testA/mysql-data:/var/lib/mysql \
--mount type=bind,source=/host/test1-testA/nginx-data,destination=/var/www \
test1:testA

sleep 5
echo "Entering..."
docker exec -ti test1-testA  bash
