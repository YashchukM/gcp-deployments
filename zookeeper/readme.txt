- Create deployment:
gcloud deployment-manager deployments create zk-deployment --config zookeeper-deployment.yaml
gcloud deployment-manager deployments create zk-deployment --config zookeeper/zookeeper-deployment.yaml

- List deployments:
gcloud deployment-manager deployments list

- Delete deployment:
gcloud deployment-manager deployments delete zk-deployment -q

- Print internal and external IPs of instances tagged with 'zookeeper'
gcloud compute instances list --format="table(networkInterfaces[0].networkIP, networkInterfaces[0].accessConfigs[0].natIP)" --filter="tags.items:zookeeper"

- Check zookeeper status
sudo docker exec -it zookeeper /opt/zookeeper/bin/zkServer.sh status

- Display last logs
sudo docker exec -it zookeeper /usr/bin/cat -n 100 /logs/zookeeper/zookeeper.log 