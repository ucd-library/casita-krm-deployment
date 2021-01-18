set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh
# source ./cmds/k8s/cluster-config/load.sh || true

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}  \
  --zone ${GC_ZONE} \
  --project ${GC_PROJECT_ID}

# additional services for default pool
kubectl apply -f ./$DEPLOYMENT_DIR/stream-status.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/stream-status.service.yaml

# scalable services
kubectl apply -f ./$DEPLOYMENT_DIR/default-worker.deployment.yaml
kubectl autoscale deployment default-worker-deployment \
  --max 15 --min 1 \
  --cpu-percent 70 || true

kubectl apply -f ./$DEPLOYMENT_DIR/generic-payload-worker.deployment.yaml
kubectl autoscale deployment generic-payload-worker-deployment \
  --max 25 --min 1 \
  --cpu-percent 70 || true

kubectl apply -f ./$DEPLOYMENT_DIR/image-worker.deployment.yaml
kubectl autoscale deployment image-worker-deployment \
  --max 50 --min 1 \
  --cpu-percent 70 || true

kubectl apply -f ./$DEPLOYMENT_DIR/stream-status-worker.deployment.yaml
kubectl autoscale deployment stream-status-worker-deployment \
  --max 5 --min 1 \
  --cpu-percent 70 || true
