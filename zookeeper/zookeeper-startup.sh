#!/bin/bash

# Additional functions
function wrap_with {
    local res
    local IFS=','
    for ip in $1; do
        if [ -z $3 ]; then
            res+=("$ip:$2")
        else
            res+=("$2://$ip:$3")
        fi
    done
    echo "${res[*]}"
}

function get_metadata {
    echo $(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/$1" -H "Metadata-Flavor: Google")
}

# Install docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker

# Get env variables from instance metadata
ZK_USER=$(get_metadata docker-user)
ZK_LOCAL_HOST=$(get_metadata local-ip)
ZK_CLUSTER_IPS=$(get_metadata cluster-ips)
ZK_CLUSTER=$(wrap_with $ZK_CLUSTER_IPS 2181)
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
