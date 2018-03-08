#!/bin/bash

# Additional functions
function join_with_port {
    local res
    local IFS=','
    for ip in $2; do
        res+=("$ip:$1")
    done
    echo "${res[*]}"
}

function wrap_with {
    local res
    local IFS=','
    for ip in $3; do
        res+=("$1://$ip:$2")
    done
    echo "${res[*]}"
}

# Install docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker

# Get env variables from instance metadata
ZK_CLUSTER_IPS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/zk-cluster-ips -H "Metadata-Flavor: Google")
ZK_CLUSTER=$(join_with_port 2181 $ZK_CLUSTER_IPS)

KAFKA_USER=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker-user -H "Metadata-Flavor: Google")
KAFKA_ID=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/kafka-id -H "Metadata-Flavor: Google")
KAFKA_CLUSTER_IPS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/cluster-ips -H "Metadata-Flavor: Google")
KAFKA_HEAP_OPTS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/heap-opts -H "Metadata-Flavor: Google")
KAFKA_RUN_UID=$(id $KAFKA_USER -u)
KAFKA_RUN_GID=$(id $KAFKA_USER -g)
KAFKA_ADVERTISED_LISTENERS=$(wrap_with PLAINTEXT 9092 $KAFKA_CLUSTER_IPS)

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
