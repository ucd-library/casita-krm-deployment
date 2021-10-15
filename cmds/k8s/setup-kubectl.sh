#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR/../..

source ./config.sh

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}  \
  --zone ${GC_ZONE} \
  --project ${GC_PROJECT_ID}