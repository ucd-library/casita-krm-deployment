set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh
# source ./cmds/k8s/cluster-config/load.sh || true

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}  \
  --zone ${GC_ZONE} \
  --project ${GC_PROJECT_ID}

# shared volume for workers and services
kubectl create -f ./$DEPLOYMENT_DIR/nfs.volume.yaml || true
kubectl apply -f ./$DEPLOYMENT_DIR/nfs.volumeclaim.yaml