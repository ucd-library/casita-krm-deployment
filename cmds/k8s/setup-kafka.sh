set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh
# source ./cmds/k8s/cluster-config/load.sh || true

kubectl apply -f ./$DEPLOYMENT_DIR/zookeeper.statefulset.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/zookeeper.service.yaml

# kubectl delete deploy kafka || true
kubectl apply -f ./$DEPLOYMENT_DIR/kafka.statefulset.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/kafka.service.yaml