#!/bin/bash

# Additional function
function join_with_port {
    local res
    local IFS=','
    for ip in $2; do
        res+=("$ip:$1")
    done
    echo "${res[*]}"
}

# Install docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker

# Get env variables from instance metadata
ZK_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker-user -H "Metadata-Flavor: Google")
ZK_LOCAL_HOST=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/local-ip -H "Metadata-Flavor: Google")
ZK_CLUSTER_IPS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/cluster-ips -H "Metadata-Flavor: Google")
ZK_CLUSTER=$(join_with_port 2181 $ZK_CLUSTER_IPS)
ZK_RUN_UID=$(id $ZK_USER -u)
ZK_RUN_GID=$(id $ZK_USER -g)

# Pull and run image
sudo docker run \
    --env ZK_CLUSTER="$ZK_CLUSTER" \
    --env ZK_LOCAL_HOST=$ZK_LOCAL_HOST \
    --env ZK_RUN_UID=$ZK_RUN_UID \
    --env ZK_RUN_GID=$ZK_RUN_GID \
    --volume /data/zookeeper:/data/zookeeper \
    --volume /logs/zookeeper:/logs/zookeeper \
    --publish 2181:2181 \
    --publish 2888:2888 \
    --publish 3888:3888 \
    --detach --interactive --tty \
    --restart always \
    --name zookeeper \
    myashchuk/zookeeper:3.4.11
