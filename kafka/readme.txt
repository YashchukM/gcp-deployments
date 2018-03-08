- Create deployment:
gcloud deployment-manager deployments create kafka-deployment --config kafka-deployment.yaml
gcloud deployment-manager deployments create kafka-deployment --config kafka/kafka-deployment.yaml

- List deployments:
gcloud deployment-manager deployments list

- Delete deployment:
gcloud deployment-manager deployments delete kafka-deployment -q
