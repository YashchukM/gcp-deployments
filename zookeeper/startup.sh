#!/bin/bash

# Install docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker

# Pull and run image
# docker run \
#     --env ZK_CLUSTER="host:port,host:port" \
#     --env ZK_LOCAL_HOST="local.host.ip" \
#     --env ZK_RUN_UID="$UID" \
#     --env ZK_RUN_GID="$(id $(whoami) -g)" \
#     --volume /data/zookeeper:/data/zookeeper \
#     --volume /logs/zookeeper:/logs/zookeeper \
#     --publish 2181:2181 \
#     --publish 2888:2888 \
#     --publish 3888:3888 \
#     --detach --interactive --tty \
#     --restart always \
#     --name zookeeper \
#     myashchuk/zookeeper:3.4.11