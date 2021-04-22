set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh
# source ./cmds/k8s/cluster-config/load.sh || true

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}  \
  --zone ${GC_ZONE} \
  --project ${GC_PROJECT_ID}

kubectl apply -f ./$DEPLOYMENT_DIR/mongo.statefulset.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/mongo.service.yaml

kubectl apply -f ./$DEPLOYMENT_DIR/rabbitmq.statefulset.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/rabbitmq.service.yaml

kubectl apply -f ./$DEPLOYMENT_DIR/api.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/api.service.yaml

kubectl apply -f ./$DEPLOYMENT_DIR/router.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/controller.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/expire.deployment.yaml
kubectl autoscale deployment  expire-deployment \
  --max 3 --min 2 \
  --cpu-percent 50 || true

kubectl apply -f ./$DEPLOYMENT_DIR/h2.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/h2.service.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/ws.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/ws.service.yaml