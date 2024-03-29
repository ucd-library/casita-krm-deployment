#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

source ../../config.sh

# if [[ -z "$1" ]]; then 
#   source ./cluster-config/load.sh
# else
#   GKE_CLUSTER_NAME=$1
# fi

echo "Setting secrets for ${GKE_CLUSTER_NAME}"

# setup kubectl to connect to cluster
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}  \
  --zone ${GC_ZONE} \
  --project ${GC_PROJECT_ID}

kubectl delete secret decoder-ssh-key || true
kubectl create secret generic decoder-ssh-key --from-file=docker.key=../../docker.key || true

kubectl delete secret service-account|| true
kubectl create secret generic service-account --from-file=service-account.json=../../service-account.json || true

echo 'Make sure and set the decoder-ssh-user secret:'
echo 'kubectl create secret generic decoder-ssh-user --from-literal=ssh-username=""'

echo 'Make sure and set the jwt-secret secret:'
echo 'kubectl create secret generic jwt-secret --from-literal=value=""'