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
ZK_CLUSTER_IPS=$(get_metadata zk-cluster-ips)
ZK_CLUSTER=$(wrap_with $ZK_CLUSTER_IPS 2181)

KAFKA_USER=$(get_metadata docker-user)
KAFKA_ID=$(get_metadata kafka-id)
KAFKA_CLUSTER_IPS=$(get_metadata cluster-ips)
KAFKA_HEAP_OPTS=$(get_metadata heap-opts)
KAFKA_RUN_UID=$(id $KAFKA_USER -u)
KAFKA_RUN_GID=$(id $KAFKA_USER -g)
KAFKA_ADVERTISED_LISTENERS=$(wrap_with $KAFKA_CLUSTER_IPS PLAINTEXT 9092)

# Pull and run image
sudo docker run \
    --env ZK_CLUSTER="$ZK_CLUSTER" \
    --env KAFKA_ID=$KAFKA_ID \
    --env KAFKA_ADVERTISED_LISTENERS="$KAFKA_ADVERTISED_LISTENERS" \
    --env KAFKA_RUN_UID=$KAFKA_RUN_UID \
    --env KAFKA_RUN_GID=$KAFKA_RUN_GID \
    --env KAFKA_HEAP_OPTS="$KAFKA_HEAP_OPTS" \
    --volume /data/kafka:/data/kafka \
    --volume /logs/kafka:/logs/kafka \
    --publish 9092:9092 \
    --detach --interactive --tty \
    --restart always \
    --name kafka \
    myashchuk/kafka:1.0.0
