- Create deployment:
gcloud deployment-manager deployments create net-deployment --config network-deployment.yaml
gcloud deployment-manager deployments create net-deployment --config network/network-deployment.yaml

- List deployments:
gcloud deployment-manager deployments list

- Delete deployment:
gcloud deployment-manager deployments delete net-deployment -q
