#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR
source ../config.sh

# reserve address to expose api internaly
gcloud compute addresses create ${GKE_CLUSTER_NAME}-api-ip \
  --subnet default \
  --region us-central1

# print info about new address
echo ""
echo "api service internal ip"
gcloud compute addresses describe ${GKE_CLUSTER_NAME}-api-ip \
  --region us-central1

# reserve address to expose h2 service internaly
gcloud compute addresses create ${GKE_CLUSTER_NAME}-h2-ip \
  --subnet default \
  --region us-central1

# print info about new address
echo ""
echo "h2 service internal ip"
gcloud compute addresses describe ${GKE_CLUSTER_NAME}-h2-ip \
  --region us-central1