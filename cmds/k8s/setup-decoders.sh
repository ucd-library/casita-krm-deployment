set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh
# source ./cmds/k8s/cluster-config/load.sh || true

kubectl apply -f ./$DEPLOYMENT_DIR/decoder-krm-interface.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/decoder.deployment.yaml
kubectl apply -f ./$DEPLOYMENT_DIR/secdecoder.deployment.yaml

