#!/bin/bash
docker ps
docker container stop john1-test1
echo "Running..."
docker  start test1-testA
sleep 3
echo "Entering..."
docker exec -ti test1-testA  bash
