#! /bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../../config.sh

# Create cluster with default pool
gcloud beta container clusters create ${GKE_CLUSTER_NAME} \
  --zone ${GC_ZONE} \
  --num-nodes 3 \
  --disk-size 20GB \
  --release-channel=regular \
  --machine-type e2-medium \
  --node-labels=intendedfor=krm-services
  # --cluster-version=${GKE_CLUSTER_VERSION} \

# create decoder instance
gcloud beta container node-pools create decoders \
  --cluster ${GKE_CLUSTER_NAME} \
  --zone ${GC_ZONE} \
  --machine-type e2-medium \
  --num-nodes 1 \
  --disk-size 20GB \
  --node-labels=intendedfor=decoders

# create kafka instance
gcloud beta container node-pools create kafka \
  --cluster ${GKE_CLUSTER_NAME} \
  --zone ${GC_ZONE} \
  --machine-type e2-medium \
  --num-nodes 1 \
  --disk-size 20GB \
  --node-labels=intendedfor=kafka

# create scalable worker pool
gcloud beta container node-pools create worker-pool \
  --cluster ${GKE_CLUSTER_NAME} \
  --zone ${GC_ZONE} \
  --machine-type c2-standard-4 \
  --num-nodes 2 \
  --disk-size 25GB \
  --preemptible \
  --node-labels=intendedfor=worker \
  --enable-autoscaling --min-nodes 1 --max-nodes 6
# --machine-type n2-standard-4 \

# set cluster secrets
$ROOT_DIR/setup-secrets.sh