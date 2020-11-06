set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh
source ./cmds/k8s/cluster-config/load.sh || true

if [[ ! -f "./cmds/k8s/cluster-config/$BRANCH_NAME.sh" ]] ; then
  echo "./cmds/k8s/cluster-config/$BRANCH_NAME.sh does not exist, skipping deployment"
  exit
fi

kubectl apply -f ./$DEPLOYMENT_DIR/zookeeper.statefulset.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/zookeeper.service.yaml

kubectl apply -f ./$DEPLOYMENT_DIR/kafka.statefulset.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/kafka.service.yaml